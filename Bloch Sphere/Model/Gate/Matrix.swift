//
//  Matrix.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import SwiftData

@Model
class Matrix: Hashable {
    var value11Real: Double
    var value12Real: Double
    var value21Real: Double
    var value22Real: Double
    var value11Imaginary: Double
    var value12Imaginary: Double
    var value21Imaginary: Double
    var value22Imaginary: Double
    
    init(
    value11Real: Double = 0,
    value12Real: Double = 0,
    value21Real: Double = 0,
    value22Real: Double = 0,
    value11Imaginary: Double = 0,
    value12Imaginary: Double = 0,
    value21Imaginary: Double = 0,
    value22Imaginary: Double = 0
    ) {
        self.value11Real = value11Real
        self.value12Real = value12Real
        self.value21Real = value21Real
        self.value22Real = value22Real
        self.value11Imaginary = value11Imaginary
        self.value12Imaginary = value12Imaginary
        self.value21Imaginary = value21Imaginary
        self.value22Imaginary = value22Imaginary
    }
}
