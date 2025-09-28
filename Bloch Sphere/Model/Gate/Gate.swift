//
//  Gate.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import Foundation
import SwiftData
import ComplexModule

@Model
class Gate: Hashable, Identifiable {
    @Attribute(.unique) var name: String
    var scalar: String
    var matrix: StringsMatrix
    var id: UUID = UUID()
    
    init(name: String, scalar: String = "1", matrix: StringsMatrix) {
        self.name = name
        self.scalar = scalar
        self.matrix = matrix
    }
}
