//
//  SelectedItemView.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import SwiftUI
import ComplexModule
import SwiftData

struct SelectedMenuOptionView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Gate.name, order: .forward) private var gates: [Gate]
    @Query(sort: \Sequence.name, order: .forward) private var sequences: [Sequence]
    
    @State var viewModel: ViewModel
    
    var body: some View {
        if viewModel.selectedMenuOption == .sequences {
            NavigationStack {
                List(sequences) { sequence in
                    NavigationLink(sequence.name, value: sequence)
                }
                .navigationDestination(for: Sequence.self) { sequence in
                    SequenceDetailsView(sequence: sequence, applyGates: viewModel.applyGates)
                }
            }
            .toolbar {
                Button("New Sequence") {
                    let newSequence = Sequence(
                        name: "Empty Sequence # \(sequences.count + 1)",
                        gates: []
                    )
                    context.insert(newSequence)
                    try? context.save()
                }
            }
        } else if viewModel.selectedMenuOption == .gates {
            NavigationStack {
                List {
                    ForEach(gates) { gate in
                        NavigationLink(gate.name, value: gate)
                    }
                }
                .navigationDestination(for: Gate.self) { gate in
                    GateDetailsView(gate: gate, applyGates: viewModel.applyGates)
                }
            }
            .toolbar {
                Button("New Gate") {
                    let newGate = Gate(
                        name: "Identity Gate Example # \(gates.count + 1)",
                        scalar: 1,
                        matrix: .init(value11Real: 1.0, value22Real: 1.0)
                    )
                    context.insert(newGate)
                    try? context.save()
                }
            }
        } else if viewModel.selectedMenuOption == .qubitState {
            QubitStateView(qubit: $viewModel.qubit, basisOption: $viewModel.qubit.basis)
        }
    }
}
