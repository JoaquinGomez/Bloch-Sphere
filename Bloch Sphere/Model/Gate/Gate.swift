//
//  Gate.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import Foundation
import SwiftData

@Model
class Gate: Hashable, Identifiable {
    @Attribute(.unique) var name: String
    var scalar: Double
    var matrix: Matrix
    
    var id: UUID {
        UUID(uuidString: name) ?? .init()
    }
    
    init(name: String, scalar: Double = 1, matrix: Matrix) {
        self.name = name
        self.scalar = scalar
        self.matrix = matrix
    }
}
