//
//  SequenceDetailsView.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import SwiftUI
import SwiftData

struct SequenceDetailsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    let sequence: Sequence
    let applyGates: ([Gate]) -> Void
    
    @State private var name: String = ""
    @State private var error: String? = ""
    @State private var selectedSteps: [SequenceStep] = []
    
    @Query(sort: \Gate.name, order: .forward) private var allGates: [Gate]

    @State private var isSaveEnabled: Bool = false
    @State private var isAppendingGates: Bool = false
    @State private var showNoGatesToAttempt: Bool = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 20)
            HStack {
                Text("Name:")
                TextField("Name", text: $name)
            }
            Spacer(minLength: 20)
            if !isAppendingGates {
                VStack {
                    HStack {
                        Text("Gates:")
                        Spacer(minLength: 20)
                        Button("Append gate") {
                            if allGates.isEmpty {
                                showNoGatesToAttempt = true
                            } else {
                                isAppendingGates = true
                            }
                        }
                    }
                    List {
                        ForEach(Array(selectedSteps.enumerated()), id: \.offset) { idx, step in
                            HStack {
                                Text(step.gate.name)
                                Spacer()
                                Text("#\(step.position)")
                            }
                            .contextMenu {
                                Button("Delete") {
                                    selectedSteps.remove(at: idx)
                                    for (i, s) in selectedSteps.enumerated() { s.position = i }
                                }
                            }
                        }.onMove(perform: moveSteps)
                    }
                }
            } else {
                VStack {
                    HStack {
                        Text("Select a gate to append:")
                        Spacer(minLength: 20)
                        Button("Cancel") {
                            isAppendingGates = false
                        }
                    }
                    List(allGates) { gate in
                        HStack {
                            Text(gate.name)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let pos = selectedSteps.count
                            let step = SequenceStep(position: pos, gate: gate)
                            selectedSteps.append(step)
                            isAppendingGates = false
                        }
                    }
                }
            }
            Spacer(minLength: 50)
            HStack {
                Button(action: {
                    applyGates(sequence.steps.sorted { $0.position < $1.position }.map(\.gate))
                }) {
                    Text("Apply sequence")
                }
                Button("Delete") {
                    context.delete(sequence)
                    try? context.save()
                    dismiss()
                }
                Button("Save") {
                    updateSequence()
                }.disabled(!isSaveEnabled)
            }
            if let error = error {
                Text(error).foregroundStyle(.red).padding()
            }
            if isSaveEnabled {
                Text("Pending changes. Click Save to save or navigate away to discard.").foregroundStyle(.yellow).padding()
            }
            if isAppendingGates {
                Text("Appending a gate. Click a gate to add it or cancel to abort.").foregroundStyle(.yellow).padding()
            }
            Spacer(minLength: 20)
        }
        .onAppear(perform: loadSequenceDetails)
        .onChange(of: name) { _, newValue in
            error = newValue.isEmpty ? "Name is required" : nil
        }
        .onChange(of: name) { _, _ in
            sequenceDidChange()
        }
        .onChange(of: selectedSteps) { _, _ in
            sequenceDidChange()
        }
        .alert("No available gates", isPresented: $showNoGatesToAttempt) {
            Button("Dismiss") {
                showNoGatesToAttempt = false
            }
        } message: {
            Text("Go to the \"Gates\" section and create new gates. Save changes (if any) before navigating away")
        }
    }
    
    func loadSequenceDetails() {
        name = sequence.name
        selectedSteps = sequence.steps.sorted { $0.position < $1.position }
    }
    
    func updateSequence() {
        sequence.name = name
        for (i, step) in selectedSteps.enumerated() { step.position = i; step.sequence = sequence }
        sequence.steps = selectedSteps
        do {
            try context.save()
            isSaveEnabled = false
        } catch {
            self.error = "Save failed: \(error.localizedDescription)"
        }
    }
    
    func sequenceDidChange() {
        if name.isEmpty {
            error = "A name is required for the Sequence."
        } else {
            error = nil
        }
        isSaveEnabled = didSequenceChange()
    }
    
    func didSequenceChange() -> Bool {
        selectedSteps != sequence.steps || name != sequence.name
    }
    
    @MainActor
    func moveSteps(from source: IndexSet, to destination: Int) {
        selectedSteps.move(fromOffsets: source, toOffset: destination)
        for (i, step) in selectedSteps.enumerated() { step.position = i }
    }
}
