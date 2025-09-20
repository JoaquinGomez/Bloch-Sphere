//
//  GateDetails.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import SwiftUI

struct GateDetailsView: View {
    let gate: Gate
    let applyGates: ([Gate]) -> Void
    
    var body: some View {
        Button(action: {
            applyGates([gate])
        }) {
            Text("Apply \(gate.name) gate")
        }
    }
}
