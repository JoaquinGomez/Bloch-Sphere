//
//  GateDetails.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import SwiftUI
import SwiftData

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
        scalar = String(describing: gate.scalar)
        a11Real = String(describing: gate.matrix.value11Real)
        a11Imaginary = String(describing: gate.matrix.value11Imaginary)
        a12Real = String(describing: gate.matrix.value12Real)
        a12Imaginary = String(describing: gate.matrix.value12Imaginary)
        a21Real = String(describing: gate.matrix.value21Real)
        a21Imaginary = String(describing: gate.matrix.value21Imaginary)
        a22Real = String(describing: gate.matrix.value22Real)
        a22Imaginary = String(describing: gate.matrix.value22Imaginary)
    }
    
    func updateGate() {
        gate.name = name
        gate.scalar = Double(scalar) ?? 0
        gate.matrix.value11Real = Double(a11Real) ?? 0
        gate.matrix.value11Imaginary = Double(a11Imaginary) ?? 0
        gate.matrix.value12Real = Double(a12Real) ?? 0
        gate.matrix.value12Imaginary = Double(a12Imaginary) ?? 0
        gate.matrix.value21Real = Double(a21Real) ?? 0
        gate.matrix.value21Imaginary = Double(a21Imaginary) ?? 0
        gate.matrix.value22Real = Double(a22Real) ?? 0
        gate.matrix.value22Imaginary = Double(a22Imaginary) ?? 0
        try? context.save()
        isSaveEnabled = false
    }
    
    func gateDidChange() {
        let validGate = isGateValid()
        if !validGate {
            error = "Error: The Gate is invalid."
        } else {
            error = nil
        }
        isSaveEnabled = validGate && didGateChange()
    }
    
    func didGateChange() -> Bool {
        return gate.matrix.value11Real != Double(a11Real) ?? 0 ||
        gate.matrix.value11Imaginary != Double(a11Imaginary) ?? 0 ||
        gate.matrix.value12Real != Double(a12Real) ?? 0 ||
        gate.matrix.value12Imaginary != Double(a12Imaginary) ?? 0 ||
        gate.matrix.value21Real != Double(a21Real) ?? 0 ||
        gate.matrix.value21Imaginary != Double(a21Imaginary) ?? 0 ||
        gate.matrix.value22Real != Double(a22Real) ?? 0 ||
        gate.matrix.value22Imaginary != Double(a22Imaginary) ?? 0 ||
        gate.name != name ||
        gate.scalar != Double(scalar) ?? 0
    }
    
    func isGateValid() -> Bool {
        return  !name.isEmpty && !invalidFieldInput(scalar) && Double(scalar) != 0 && !invalidFieldInput(a11Real) && !invalidFieldInput(a11Imaginary) && !invalidFieldInput(a12Real) && !invalidFieldInput(a12Imaginary) && !invalidFieldInput(a21Real) && !invalidFieldInput(a21Imaginary) && !invalidFieldInput(a22Real) && !invalidFieldInput(a22Imaginary)
    }
    
    func invalidFieldInput(_ string: String) -> Bool {
        let invalid = Double(string) == nil || string.isEmpty
        return invalid
    }
}
