//
//  SequenceStep.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/27/25.
//

import SwiftData
import Foundation

@Model
final class SequenceStep: Identifiable, Hashable {
    var id: UUID = UUID()
    var position: Int

    @Relationship var gate: Gate
    @Relationship(inverse: \Sequence.steps) var sequence: Sequence?

    init(position: Int, gate: Gate) {
        self.position = position
        self.gate = gate
    }
}
