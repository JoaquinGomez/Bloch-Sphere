//
//  ViewModel.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import SwiftUI
import RealityKit

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
        try? spinQubitVectorEntity(Rotation(horizontalAxis: 1, verticalAxis: 1, depthAxis: 1))
    }

    func spinQubitVectorEntity(_ rotation: Rotation) throws {
        qubitVectorEntity.components.set(rotation)
        
        let spinAction = SpinAction(revolutions: 0.5, localAxis: rotation.spinAxis)
        
        let animation = try AnimationResource.makeActionAnimation(
            for: spinAction,
            duration: 1,
            bindTarget: .transform
        )
        
        qubitVectorEntity.playAnimation(animation)
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
