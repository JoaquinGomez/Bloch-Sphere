//
//  QubitStateView.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import SwiftUI
import ExpressionParser

struct QubitStateView: View {
    @Binding var qubit: Qubit
    @Binding var basisOption: BasisOption
    
    @State private var stateEquation: String = ""
    
    @State private var firstStateRealNumber: String = ""
    @State private var firstStateImaginaryNumber: String = ""
    
    @State private var secondStateRealNumber: String = ""
    @State private var secondStateImaginaryNumber: String = ""
    
    @State private var firstStateLaTex: String = ""
    @State private var secondStateLaText: String = ""
    
    @State private var error: String? = nil
    
    var body: some View {
        VStack {
            Text("Qubit State View").padding()
            Picker("Select a Basis", selection: $basisOption) {
                Text(BasisOption.computational.values().name).tag(BasisOption.computational)
                Text(BasisOption.hadamard.values().name).tag(BasisOption.hadamard)
                Text(BasisOption.pauliY.values().name).tag(BasisOption.pauliY)
            }.pickerStyle(.segmented)
            HStack {
                Text("(")
                TextField("Real", text: $firstStateRealNumber)
                Text("+")
                TextField("Imaginary", text: $firstStateImaginaryNumber)
                Text("i").italic()
                Text(")")
                MTMathUILabelRepresentable(latex: $firstStateLaTex)
            }
            HStack {
                Text("(")
                TextField("Real", text: $secondStateRealNumber)
                Text("+")
                TextField("Imaginary", text: $secondStateImaginaryNumber)
                Text("i").italic()
                Text(")")
                MTMathUILabelRepresentable(latex: $secondStateLaText)
            }
            MTMathUILabelRepresentable(latex: $stateEquation)
            Text(error ?? "").foregroundStyle(.red).padding()
        }
        .onChange(of: basisOption) { _, _ in
            updateBasisOption()
        }
        .onChange(of: firstStateRealNumber) { _, newValue in
            updateStateComponent(.firstCoeficientRealPart, value: newValue)
        }
        .onChange(of: firstStateImaginaryNumber) { _, newValue in
            updateStateComponent(.firstCoeficientImaginaryPart, value: newValue)
        }
        .onChange(of: secondStateRealNumber) { _, newValue in
            updateStateComponent(.secondCoeficientRealPart, value: newValue)
        }
        .onChange(of: secondStateImaginaryNumber) { _, newValue in
            updateStateComponent(.secondCoeficientImaginaryPart, value: newValue)
        }
        .onAppear {
            updateBasisOption()
            populateCoeficients()
        }
    }
    
    func updateBasisOption() {
        firstStateLaTex = qubit.basis.values().firstSate
        secondStateLaText = qubit.basis.values().secondState
        qubit.basis = basisOption
        updateStateEquation()
    }
    
    func populateCoeficients() {
        firstStateRealNumber = qubit.alphaReal ?? ""
        firstStateImaginaryNumber = qubit.alphaImaginary ?? ""
        secondStateRealNumber = qubit.betaReal ?? ""
        secondStateImaginaryNumber = qubit.betaImaginary ?? ""
        updateStateEquation()
    }
        
    func updateStateEquation() {
        stateEquation = "|\\psi\\rangle = \(formatNumber(firstStateRealNumber, asComplex: false)) \(formatNumber(firstStateImaginaryNumber, asComplex: true)) \(basisOption.values().firstSate) + \(formatNumber(secondStateRealNumber, asComplex: false)) \(formatNumber(secondStateImaginaryNumber, asComplex: true)) \(basisOption.values().secondState)"
    }
    
    func formatNumber(_ string: String, asComplex: Bool) -> String {
        do {
            let parsedExpression = try swiftToLaTeX(string)
            return parsedExpression.isEmpty ? "" : (asComplex ? "+(" : "") + parsedExpression + (asComplex ? ")i" : "")
        } catch {
            return ""
        }
    }
    
    func updateStateComponent(_ component: StateComponent, value: String) {
        switch component {
        case .firstCoeficientRealPart:
            qubit.alphaReal = value
        case .firstCoeficientImaginaryPart:
            qubit.alphaImaginary = value
        case .secondCoeficientRealPart:
            qubit.betaReal = value
        case .secondCoeficientImaginaryPart:
            qubit.betaImaginary = value
        }
        if !qubit.isNormalized() {
            error = "Error: Qubit state must be normalized."
        } else {
            error = ""
        }
        updateStateEquation()
    }
}
