//
//  GateStep.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/27/25.
//

struct GateStep {
    let name: String
    let axis: Axis
    let revolutions: Float
    let localAxis: SIMD3<Float>
}

enum Axis {
    case x
    case y
    case z
}
