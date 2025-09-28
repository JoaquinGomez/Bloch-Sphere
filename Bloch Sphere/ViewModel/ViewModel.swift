//
//  ViewModel.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import SwiftUI
import RealityKit
import RealModule
import ComplexModule
import simd

@Observable
public class ViewModel {
    var selectedMenuOption: MenuOption
    var basisOption: BasisOption
    var qubit: Qubit
    let qubitVectorEntity = Entity()
    
    init(selectedMenuOption: MenuOption = MenuOption.qubitState, basisOption: BasisOption = BasisOption.computational) {
        self.selectedMenuOption = selectedMenuOption
        self.basisOption = basisOption
        self.qubit = Qubit(basis: basisOption, alphaReal: "1/sqrt(2)", betaReal: "1/sqrt(2)")
    }
    
    func applyGates(_ gates: [Gate]) {
        var steps: [GateStep] = []
        gates.forEach { [weak self] gate in
            steps.append(contentsOf: self!.stepsFromGate(gate))
        }
        try? spinQubitVectorEntity(steps: steps)
    }
    
    func moveQubitVectorEntityTo(_ r: SIMD3<Float>) {
        let len = simd_length(r)
        let dir = simd_normalize(r)
        let rot = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: dir)

        qubitVectorEntity.setOrientation(rot, relativeTo: nil)
        qubitVectorEntity.setScale(SIMD3<Float>(1, len, 1), relativeTo: nil)
        qubitVectorEntity.setPosition(.zero, relativeTo: nil)
    }
    
    func stepsFromGate(_ gate: Gate) -> [GateStep] {
        let scalar = gate.scalar.numberEvaluation() ?? 1.0
        let numericMatrix = gate.matrix.numericMatrix(scalar: scalar)
        let determinant = numericMatrix.determinant()
        let sqrtDet = Complex.sqrt(determinant)
        let a = numericMatrix._11Complex/sqrtDet
        let b = numericMatrix._12Complex/sqrtDet
        let c = numericMatrix._21Complex/sqrtDet
        let d = numericMatrix._22Complex/sqrtDet
        let angleYFirstParam = min(max((a * c.conjugate - b * d.conjugate).real, -1.0), 1.0)
        let angleY = asin(angleYFirstParam)
        let angleXFirstParam = (a * c.conjugate - b * d.conjugate).imaginary
        let angleXSecondParam = a.magnitude * a.magnitude - b.magnitude * b.magnitude - c.magnitude * c.magnitude + d.magnitude * d.magnitude
        let angleX = atan2(angleXFirstParam, angleXSecondParam)
        let angleZFirstParam = -((a * d.conjugate) - (b * c.conjugate)).imaginary
        let angleZSecondParam =  ((a * d.conjugate) + (b * c.conjugate)).real
        let angleZ = atan2(angleZFirstParam, angleZSecondParam)
        
        let xBlochWorld = SIMD3<Float>(1, 0, 0)
        let yBlochWorld = SIMD3<Float>(0, 0, 1)
        let zBlochWorld = SIMD3<Float>(0, 1, 0)
        
        let xRevolutions = Float(angleX / (2 * .pi))
        let yRevolutions = Float((-angleY) / (2 * .pi))
        let zRevolutions = Float(angleZ / (2 * .pi))
        
        let steps: [GateStep] = [
            .init(name: "Z Axis Angle for \(gate.name) gate", axis: .z, revolutions: angleZ == 0 ? 0 : zRevolutions, localAxis:  zBlochWorld),
            .init(name: "Y Axis Angle for \(gate.name) gate", axis: .y, revolutions: angleY == 0 ? 0 : yRevolutions, localAxis:  yBlochWorld),
            .init(name: "X Axis Angle for \(gate.name) gate", axis: .x, revolutions: angleX == 0 ? 0 : xRevolutions, localAxis:  xBlochWorld),
        ]
        return steps
    }

    private func localAxis(forWorldAxis worldAxis: SIMD3<Float>, of entity: Entity) -> SIMD3<Float> {
        let worldToLocal = simd_inverse(entity.transformMatrix(relativeTo: nil))
        let local = worldToLocal * SIMD4<Float>(worldAxis.x, worldAxis.y, worldAxis.z, 0)
        return simd_normalize(SIMD3<Float>(local.x, local.y, local.z))
    }

    func spinQubitVectorEntity(steps: [GateStep]) throws {
        let duration: Double = 1.0

        Task {
            for (step) in steps {
                guard step.revolutions != 0 else { continue }

                let local = localAxis(forWorldAxis: step.localAxis, of: qubitVectorEntity)
                let action = SpinAction(revolutions: step.revolutions, localAxis: local)
                let anim = try AnimationResource.makeActionAnimation(
                    for: action,
                    duration: duration,
                    bindTarget: .transform
                )

                qubitVectorEntity.playAnimation(anim)
                try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            }
        }
    }


    func createGameScene(_ content: any RealityViewContentProtocol) {
        let all = Entity()
        
        let sphereRadious: Float = 1.0
        let arrowEntity = createArrowEntity(coneSize: 0.03, length: sphereRadious, cylinderRadious: 0.004, color: .cyan)
        
        qubitVectorEntity.addChild(arrowEntity)
        
        let sphere = createSphere(radious: sphereRadious)
        all.addChild(makeAxis(lenght: sphereRadious * 2 + 0.5, color: .green, orientation: [0, 1, 0], positiveLabel: "|0⟩", negativeLabel: "|𝟣⟩"))
        all.addChild(makeAxis(lenght: sphereRadious * 2 + 0.5, color: .red, orientation: [0, 0, -1], positiveLabel: "|+⟩", negativeLabel: "|-⟩"))
        all.addChild(makeAxis(lenght: sphereRadious * 2 + 0.5, color: .blue, orientation: [1, 0, 0], positiveLabel: "|i⟩", negativeLabel: "|-i⟩"))
        all.addChild(sphere)
        all.addChild(qubitVectorEntity)
        content.add(all)
        content.add(createCamera())
    }
    
    func createSphere(radious: Float) -> Entity {
        var sphereMaterial = PhysicallyBasedMaterial()
        sphereMaterial.baseColor = .init(tint: .white)
        sphereMaterial.blending = .transparent(opacity: 0.05)
        sphereMaterial.roughness = 0.0
        sphereMaterial.metallic = 0.0
        
        let sphereComponent = ModelComponent(mesh: .generateSphere(radius: radious), materials: [sphereMaterial])
        let sphereEntity = Entity()
        sphereEntity.components.set([sphereComponent])
        return sphereEntity
    }
    
    func createArrowEntity(coneSize: Float, length: Float, cylinderRadious: Float, color: NSColor) -> Entity {
        let arrowEntity = Entity()
        
        let material = SimpleMaterial(color: color, isMetallic: true)
        
        let coneComponent = ModelComponent(
            mesh: .generateCone(height: coneSize, radius: coneSize),
            materials: [material]
        )
        let coneEntity = Entity()
        coneEntity.components.set([coneComponent])
        coneEntity.position.y = length - coneSize / 2
        arrowEntity.addChild(coneEntity)
        
        let cylinderLenght = length - coneSize
        let cylinderComponent = ModelComponent(
            mesh: .generateCylinder(height: cylinderLenght, radius: cylinderRadious),
            materials: [material]
        )
        let cylinderEntity = Entity()
        cylinderEntity.components.set([cylinderComponent])
        cylinderEntity.position.y = cylinderLenght/2
        arrowEntity.addChild(cylinderEntity)
        
        let perpendicularIndicatorsLenght = 4 * coneSize
        
        arrowEntity.addChild(createPerpendicularComponent(orientation: [1, 0, 0], length: perpendicularIndicatorsLenght, radious: cylinderRadious, yPosition: length / 2, color: .cyan, xPosition: 0, zPosition: perpendicularIndicatorsLenght/2, label: "a"))
        arrowEntity.addChild(createPerpendicularComponent(orientation: [0, 0, 1], length: perpendicularIndicatorsLenght, radious: cylinderRadious, yPosition: length / 2, color: .cyan, xPosition: -perpendicularIndicatorsLenght/2, zPosition: 0, label: "b"))
        arrowEntity.addChild(createPerpendicularComponent(orientation: [1, 0, 0], length: perpendicularIndicatorsLenght, radious: cylinderRadious, yPosition: length / 2, color: .cyan, xPosition: 0, zPosition: -perpendicularIndicatorsLenght/2, label: "c"))
        arrowEntity.addChild(createPerpendicularComponent(orientation: [0, 0, 1], length: perpendicularIndicatorsLenght, radious: cylinderRadious, yPosition: length / 2, color: .cyan, xPosition: perpendicularIndicatorsLenght/2, zPosition: 0, label: "d"))
        
        return arrowEntity
    }
    
    func createPerpendicularComponent(orientation: SIMD3<Float>, length: Float, radious: Float, yPosition: Float, color: NSColor, xPosition: Float, zPosition: Float, label: String) -> Entity {
        let material = SimpleMaterial(color: color, isMetallic: true)
        let perpendicularEntity = Entity()
        let perpendicularComponent = ModelComponent(mesh: .generateCylinder(height: length, radius: radious), materials: [material])
        perpendicularEntity.components.set([perpendicularComponent])
        perpendicularEntity.position.y = yPosition
        perpendicularEntity.position.x = xPosition
        perpendicularEntity.position.z = zPosition
        perpendicularEntity.orientation = simd_quatf(angle: .pi/2, axis: orientation)
        let labelText = makeText(label, position: [0, 2*xPosition, 0], color: .yellow)
        perpendicularEntity.addChild(labelText)
        return perpendicularEntity
    }
    
    func createCamera() -> Entity {
        let camera = Entity()
        camera.components.set(PerspectiveCameraComponent())
        
        let cameraLocation: SIMD3<Float> = [0, 0, 2.5]
        camera.look(at: .zero, from: cameraLocation, relativeTo: nil)
        
        return camera
    }
    
    func makeAxis(lenght: Float, color: NSColor, orientation: SIMD3<Float>, positiveLabel: String, negativeLabel: String) -> Entity {
        let axisMaterial = SimpleMaterial(color: color, roughness: 1.0, isMetallic: false)
        let axisComponent = ModelComponent(mesh: .generateCylinder(height: lenght, radius: 0.003), materials: [axisMaterial])
        let axisEntity = Entity()
        let positiveLabelText = makeText(positiveLabel, position: [0, 1, 0], color: .yellow)
        axisEntity.addChild(positiveLabelText)
        let negativeLabelText = makeText(negativeLabel, position: [0, -1, 0], color: .yellow)
        axisEntity.addChild(negativeLabelText)
        axisEntity.orientation = simd_quatf(angle: .pi/2, axis: orientation)
        axisEntity.components.set([axisComponent])
        return axisEntity
    }
    
    func makeText(_ string: String, position: SIMD3<Float>, color: NSColor) -> Entity {
        let font = MeshResource.Font.systemFont(ofSize: 0.05)
        let textMesh = MeshResource.generateText(
            string,
            extrusionDepth: 0.001,
            font: font,
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let material = SimpleMaterial(color: color,
                                      roughness: 0.5,
                                      isMetallic: false)

        let textEntity = ModelEntity(mesh: textMesh, materials: [material])

        textEntity.position = position
        textEntity.components.set(BillboardComponent())

        return textEntity
    }
}
