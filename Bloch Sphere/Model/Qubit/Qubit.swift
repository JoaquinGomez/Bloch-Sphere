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
        .init(numberFrom(alphaReal ?? "0"), numberFrom(alphaImaginary ?? "0"))
    }
    
    var beta: Complex<Double> {
        .init(numberFrom(betaReal ?? "0"), numberFrom(betaImaginary ?? "0"))
    }
    
    func isNormalized() -> Bool {
        let a = alpha.magnitude * alpha.magnitude
        let b = beta.magnitude * beta.magnitude
        print(a)
        print(b)
        let sum = a + b
        let magnitude = sum.squareRoot()
        return magnitude <= 1.0000000000000002 && magnitude >= 0.9999999999999998
    }
    
    func numberFrom(_ expression: String) -> Double {
        print(expression)
        do {
            return try MathEval.evaluate(expression)
        } catch {
            print("error")
            return 0
        }
    }
}
