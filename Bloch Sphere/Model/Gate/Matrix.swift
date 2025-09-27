//
//  Matrix.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import ComplexModule

struct Matrix: Hashable {
    var _11Complex: Complex<Double>
    var _21Complex: Complex<Double>
    var _12Complex: Complex<Double>
    var _22Complex: Complex<Double>
    
    init(
    _11Complex: Complex<Double>,
    _21Complex: Complex<Double>,
    _12Complex: Complex<Double>,
    _22Complex: Complex<Double>,
    ) {
        self._11Complex = _11Complex
        self._12Complex = _12Complex
        self._21Complex = _21Complex
        self._22Complex = _22Complex
    }
    
    func dagger() -> Matrix {
        .init(
            _11Complex: _11Complex.conjugate,
            _21Complex: _12Complex.conjugate,
            _12Complex: _21Complex.conjugate,
            _22Complex: _22Complex.conjugate
        )
    }
    
    static func * (a: Matrix, b: Matrix) -> Matrix {
        return Matrix(
            _11Complex: (a._11Complex * b._11Complex + a._12Complex * b._21Complex),
            _21Complex: (a._21Complex * b._11Complex + a._22Complex * b._21Complex),
            _12Complex: (a._11Complex * b._12Complex + a._12Complex * b._22Complex),
            _22Complex: (a._21Complex * b._12Complex + a._22Complex * b._22Complex)   
        )
    }
    
    static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        equalWithinTolerance(lhs._11Complex, rhs._11Complex, tolerance: 0.0000000000000003) &&
        equalWithinTolerance(lhs._12Complex, rhs._12Complex, tolerance: 0.0000000000000003) &&
        equalWithinTolerance(lhs._21Complex, rhs._21Complex, tolerance: 0.0000000000000003) &&
        equalWithinTolerance(lhs._22Complex, rhs._22Complex, tolerance: 0.0000000000000003)
    }
    
    func determinant() -> Complex<Double> {
        _11Complex * _22Complex - _12Complex * _21Complex
    }
    
    static func equalWithinTolerance(_ lhs: Complex<Double>, _ rhs: Complex<Double>, tolerance: Double) -> Bool {
        let delta = lhs - rhs
        let deltaMagnitude = delta.magnitude
        return deltaMagnitude >= -tolerance && deltaMagnitude <= tolerance
    }
}
