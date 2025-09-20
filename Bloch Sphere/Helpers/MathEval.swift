//
//  MathEval.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import Expression
import Foundation
typealias Expression = NumericExpression

enum MathEval {
    static let constants: [String: Double] = [
        "e": Foundation.exp(1.0),
    ]

    static let symbols: [Expression.Symbol: Expression.SymbolEvaluator] = [
        .function("exp", arity: 1): { args in Foundation.exp(args[0]) },
        .function("ln",  arity: 1): { args in Foundation.log(args[0]) },
        .function("log10", arity: 1): { args in Foundation.log10(args[0]) }
    ]

    static func evaluate(_ s: String) throws -> Double {
        try Expression(s, constants: constants, symbols: symbols).evaluate()
    }
}
