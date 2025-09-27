//
//  StringMathEval.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/27/25.
//

extension String {
    func numberEvaluation() -> Double? {
        do {
            let result = try MathEval.evaluate(self)
            return result
        } catch {
            return nil
        }
    }
}
