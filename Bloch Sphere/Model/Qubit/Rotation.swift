//
//  SpinComponent.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import RealityKit

struct Rotation: Component {
    let spinAxis: SIMD3<Float>
    
    init(horizontalAxis: Float, verticalAxis: Float, depthAxis: Float) {
        spinAxis = SIMD3(horizontalAxis, verticalAxis, depthAxis)
    }
}
