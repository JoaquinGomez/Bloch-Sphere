//
//  Sequence.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import Foundation
import SwiftData

@Model
class Sequence: Hashable, Identifiable {
    @Attribute(.unique) var name: String
    var gates: [Gate]
    
    var id: UUID {
        UUID(uuidString: name) ?? .init()
    }
    
    init(name: String, gates: [Gate]) {
        self.name = name
        self.gates = gates
    }
}
