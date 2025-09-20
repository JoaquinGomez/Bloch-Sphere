//
//  SequenceDetailsView.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import SwiftUI

struct SequenceDetailsView: View {
    let sequence: Sequence
    let applyGates: ([Gate]) -> Void
    
    var body: some View {
        Button(action: {
            applyGates(sequence.gates)
        }) {
            Text("Apply \(sequence.name) sequence")
        }
    }
}
