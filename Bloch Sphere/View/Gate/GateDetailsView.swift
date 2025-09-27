//
//  GateDetails.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import SwiftUI
import SwiftData
import ComplexModule

struct GateDetailsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    @State private var error: String? = nil
    @State private var isSaveEnabled: Bool = false
    
    @State private var a11Real: String = ""
    @State private var a11Imaginary: String = ""
    @State private var a12Real: String = ""
    @State private var a12Imaginary: String = ""
    @State private var a21Real: String = ""
    @State private var a21Imaginary: String = ""
    @State private var a22Real: String = ""
    @State private var a22Imaginary: String = ""
    @State private var scalar: String = ""
    @State private var name: String = ""
    
    let gate: Gate
    let applyGates: ([Gate]) -> Void
    
    var body: some View {
        VStack {
            Spacer(minLength: 20)
            HStack {
                Text("Name:")
                TextField("Name", text: $name)
            }
            Spacer(minLength: 20)
            VStack {
                Text("Scalar")
                HStack {
                    Spacer(minLength: 20)
                    TextField("Scalar", text: $scalar)
                    Spacer(minLength: 20)
                }
            }
            Spacer(minLength: 20)
            VStack {
                Text("Matrix")
                HStack {
                    Spacer(minLength: 20)
                    VStack {
                        Text("a11")
                        HStack {
                            TextField("Real", text: $a11Real)
                            Text("+")
                            TextField("Imaginary", text: $a11Imaginary)
                            Text("i,").italic()
                        }
                    }
                    Spacer(minLength: 20)
                    VStack {
                        Text("a12")
                        HStack {
                            TextField("Real", text: $a12Real)
                            Text("+")
                            TextField("Imaginary", text: $a12Imaginary)
                            Text("i,").italic()
                        }
                    }
                    Spacer(minLength: 20)
                }
                HStack {
                    Spacer(minLength: 20)
                    VStack {
                        Text("a21")
                        HStack {
                            TextField("Real", text: $a21Real)
                            Text("+")
                            TextField("Imaginary", text: $a21Imaginary)
                            Text("i,").italic()
                        }
                    }
                    Spacer(minLength: 20)
                    VStack {
                        Text("a22")
                        HStack {
                            TextField("Real", text: $a22Real)
                            Text("+")
                            TextField("Imaginary", text: $a22Imaginary)
                            Text("i,").italic()
                        }
                    }
                    Spacer(minLength: 20)
                }
            }
            Spacer(minLength: 50)
            HStack {
                Button(action: {
                    applyGates([gate])
                }) {
                    Text("Apply gate")
                }
                Button("Delete") {
                    context.delete(gate)
                    try? context.save()
                    dismiss()
                }
                Button("Save") {
                    updateGate()
                }.disabled(!isSaveEnabled)
            }
            if let error = error {
                Text(error).foregroundStyle(.red).padding()
            }
            if isSaveEnabled {
                Text("Pending changes. Click Save to save or navigate away to discard.").foregroundStyle(.yellow).padding()
            }
            Spacer(minLength: 20)
        }
        .onAppear(perform: loadGateDetails)
        .onChange(of: a11Real) { _, _ in
            gateDidChange()
        }
        .onChange(of: a11Imaginary) { _, _ in
            gateDidChange()
        }
        .onChange(of: a12Real) { _, _ in
            gateDidChange()
        }
        .onChange(of: a12Imaginary) { _, _ in
            gateDidChange()
        }
        .onChange(of: a21Real) { _, _ in
            gateDidChange()
        }
        .onChange(of: a21Imaginary) { _, _ in
            gateDidChange()
        }
        .onChange(of: a22Real) { _, _ in
            gateDidChange()
        }
        .onChange(of: a22Imaginary) { _, _ in
            gateDidChange()
        }
        .onChange(of: scalar) { _, _ in
            gateDidChange()
        }
        .onChange(of: name) { _, _ in
            gateDidChange()
        }
    }
    
    func loadGateDetails() {
        name = gate.name
        scalar = gate.scalar
        a11Real = gate.matrix.a11Real
        a11Imaginary = gate.matrix.a11Imaginary
        a12Real = gate.matrix.a12Real
        a12Imaginary = gate.matrix.a12Imaginary
        a21Real = gate.matrix.a21Real
        a21Imaginary = gate.matrix.a21Imaginary
        a22Real = gate.matrix.a22Real
        a22Imaginary = gate.matrix.a22Imaginary
    }
    
    func updateGate() {
        gate.name = name
        gate.scalar = scalar
        gate.matrix.a11Real = a11Real
        gate.matrix.a11Imaginary = a11Imaginary
        gate.matrix.a12Real = a12Real
        gate.matrix.a12Imaginary = a12Imaginary
        gate.matrix.a21Real = a21Real
        gate.matrix.a21Imaginary = a21Imaginary
        gate.matrix.a22Real = a22Real
        gate.matrix.a22Imaginary = a22Imaginary
        try? context.save()
        isSaveEnabled = false
    }
    
    func gateDidChange() {
        let isInputValid = isInputValid()
        if !isInputValid {
            error = "Error: The input is invalid."
        } else {
            error = nil
        }
        let isGateUnitary = isGateUnitary()
        if !isGateUnitary {
            error = "Error: The gate is not unitary"
        } else if isInputValid {
            error = nil
        }
        isSaveEnabled = isInputValid && isGateUnitary && didGateChange()
    }
    
    func didGateChange() -> Bool {
        return gate.matrix.a11Real != a11Real ||
        gate.matrix.a11Imaginary != a11Imaginary ||
        gate.matrix.a12Real != a12Real ||
        gate.matrix.a12Imaginary != a12Imaginary ||
        gate.matrix.a21Real != a21Real ||
        gate.matrix.a21Imaginary != a21Imaginary ||
        gate.matrix.a22Real != a22Real ||
        gate.matrix.a22Imaginary != a22Imaginary ||
        gate.name != name ||
        gate.scalar != scalar
    }
    
    func isInputValid() -> Bool {
        return  !name.isEmpty && !invalidFieldInput(scalar) && Double(scalar) != 0 && !invalidFieldInput(a11Real) && !invalidFieldInput(a11Imaginary) && !invalidFieldInput(a12Real) && !invalidFieldInput(a12Imaginary) && !invalidFieldInput(a21Real) && !invalidFieldInput(a21Imaginary) && !invalidFieldInput(a22Real) && !invalidFieldInput(a22Imaginary)
    }
    
    func invalidFieldInput(_ string: String) -> Bool {
        let invalid = string.numberEvaluation() == nil || string.isEmpty
        return invalid
    }
    
    func isGateUnitary() -> Bool {
        let matrixCandidate = StringsMatrix(a11Real: a11Real, a12Real: a12Real, a21Real: a21Real, a22Real: a22Real, a11Imaginary: a11Imaginary, a12Imaginary: a12Imaginary, a21Imaginary: a21Imaginary, a22Imaginary: a22Imaginary).numericMatrix(scalar: scalar.numberEvaluation() ?? 1)
        let matrix = matrixCandidate.dagger() * matrixCandidate
        return matrix == Matrix(_11Complex: .init(1), _21Complex: .init(0), _12Complex: .init(0), _22Complex: .init(1))
    }
}
