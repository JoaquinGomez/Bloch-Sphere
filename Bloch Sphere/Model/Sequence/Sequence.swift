//
//  Sequence.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import Foundation

struct Sequence: Hashable, Identifiable {
    let name: String
    let gates: [Gate]
    
    var id: UUID {
        UUID(uuidString: name) ?? .init()
    }
    
    init(name: String, gates: [Gate]) {
        self.name = name
        self.gates = gates
    }
}
