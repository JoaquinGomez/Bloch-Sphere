//
//  Gate.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import Foundation

struct Gate: Hashable, Identifiable {
    let name: String
    let scalar: Double
    let matrix: Matrix
    
    var id: UUID {
        UUID(uuidString: name) ?? .init()
    }
    
    init(name: String, scalar: Double = 1, matrix: Matrix) {
        self.name = name
        self.scalar = scalar
        self.matrix = matrix
    }
}
