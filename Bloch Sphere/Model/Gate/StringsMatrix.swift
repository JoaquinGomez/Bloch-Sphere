//
//  Matrix.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import SwiftData
import ComplexModule

@Model
class StringsMatrix: Hashable {
    var a11Real: String
    var a12Real: String
    var a21Real: String
    var a22Real: String
    var a11Imaginary: String
    var a12Imaginary: String
    var a21Imaginary: String
    var a22Imaginary: String
    
    init(
    a11Real: String = "",
    a12Real: String = "",
    a21Real: String = "",
    a22Real: String = "",
    a11Imaginary: String = "",
    a12Imaginary: String = "",
    a21Imaginary: String = "",
    a22Imaginary: String = ""
    ) {
        self.a11Real = a11Real
        self.a12Real = a12Real
        self.a21Real = a21Real
        self.a22Real = a22Real
        self.a11Imaginary = a11Imaginary
        self.a12Imaginary = a12Imaginary
        self.a21Imaginary = a21Imaginary
        self.a22Imaginary = a22Imaginary
    }

    func numericMatrix(scalar: Double) -> Matrix {
        return Matrix(
            _11Complex: Self.complexFromStrings(real: a11Real, imaginary: a11Imaginary, scalar: scalar),
            _21Complex: Self.complexFromStrings(real: a21Real, imaginary: a21Imaginary, scalar: scalar),
            _12Complex: Self.complexFromStrings(real: a12Real, imaginary: a12Imaginary, scalar: scalar),
            _22Complex: Self.complexFromStrings(real: a22Real, imaginary: a22Imaginary, scalar: scalar),
        )
    }
    
    private static func complexFromStrings(real: String, imaginary: String, scalar: Double) -> Complex<Double> {
        Complex(
            scalar * (real.numberEvaluation() ?? 0),
            scalar * (imaginary.numberEvaluation() ?? 0)
        )
    }
}
