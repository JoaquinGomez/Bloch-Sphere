//
//  Matrix.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import ComplexModule

struct Matrix: Hashable {
    let value11: Complex<Double>
    let value12: Complex<Double>
    let value21: Complex<Double>
    let value22: Complex<Double>
    
    init(
        value11: Complex<Double> = Complex<Double>(0, 0),
        value12: Complex<Double> = Complex<Double>(0, 0),
        value21: Complex<Double> = Complex<Double>(0, 0),
        value22: Complex<Double> = Complex<Double>(0, 0)
    ) {
        self.value11 = value11
        self.value12 = value12
        self.value21 = value21
        self.value22 = value22
    }
}
