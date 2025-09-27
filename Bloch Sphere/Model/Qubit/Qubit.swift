//
//  Untitled.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import ComplexModule
import Expression

struct Qubit: Hashable {
    var basis: BasisOption
    
    var alphaReal: String?
    var alphaImaginary: String?
    var betaReal: String?
    var betaImaginary: String?
    
    var alpha: Complex<Double> {
        .init(alphaReal?.numberEvaluation() ?? 0, alphaImaginary?.numberEvaluation() ?? 0)
    }
    
    var beta: Complex<Double> {
        .init(betaReal?.numberEvaluation() ?? 0, betaImaginary?.numberEvaluation() ?? 0)
    }
    
    func isNormalized() -> Bool {
        let a = alpha.magnitude * alpha.magnitude
        let b = beta.magnitude * beta.magnitude
        let sum = a + b
        let magnitude = sum.squareRoot()
        return magnitude <= 1.0000000000000002 && magnitude >= 0.9999999999999998
    }
}
