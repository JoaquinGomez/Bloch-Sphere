//
//  SelectedItemView.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import SwiftUI
import ComplexModule

struct SelectedMenuOptionView: View {
    @State var viewModel: ViewModel
    
    let gates: [Gate] = [
        .init(
            name: "Hadamard",
            scalar: 1/sqrt(2),
            matrix: .init(
                value11: .init(1, 0),
                value12: .init(1, 0),
                value21: .init(1, 0),
                value22: .init(-1, 0)
            )
        )
    ]
    
    let sequences: [Sequence] = [
        .init(
            name: "Hadamard Gate Twice", gates: [
                .init(
                    name: "H",
                    scalar: 1/sqrt(2),
                    matrix: .init(
                        value11: .init(1, 0),
                        value12: .init(1, 0),
                        value21: .init(1, 0),
                        value22: .init(-1, 0)
                    )
                ),
                .init(
                    name: "H",
                    scalar: 1/sqrt(2),
                    matrix: .init(
                        value11: .init(1, 0),
                        value12: .init(1, 0),
                        value21: .init(1, 0),
                        value22: .init(-1, 0)
                    )
                )
            ]
        )
    ]
    
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
        } else if viewModel.selectedMenuOption == .gates {
            NavigationStack {
                List(gates) { gate in
                    NavigationLink(gate.name, value: gate)
                }
                .navigationDestination(for: Gate.self) { gate in
                    GateDetailsView(gate: gate, applyGates: viewModel.applyGates)
                }
            }
        } else if viewModel.selectedMenuOption == .qubitState {
            QubitStateView(qubit: $viewModel.qubit, basisOption: $viewModel.qubit.basis)
        }
    }
}
