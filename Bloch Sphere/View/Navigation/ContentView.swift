//
//  ContentView.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var viewModel = ViewModel(selectedMenuOption: .qubitState, basisOption: .computational)
    
    var body: some View {
        NavigationSplitView {
            TopMenuView(selectedMenuOption: $viewModel.selectedMenuOption)
        } content: {
            SelectedMenuOptionView(viewModel: viewModel)
        } detail: {
            RealityView { content in
                createGameScene(content)
            }.gesture(tapEntityGesture)
            .realityViewCameraControls(.orbit)
        }
    }

    var tapEntityGesture: some Gesture {
        TapGesture().targetedToEntity(where: .has(Rotation.self))
            .onEnded({ gesture in
                try? spinEntity(gesture.entity)
            })
    }
    
    fileprivate func createGameScene(_ content: any RealityViewContentProtocol) {
        let boxSize: SIMD3<Float> = [0.2, 0.2, 0.2]
        
        let boxModel = ModelComponent(
            mesh: .generateBox(size: boxSize),
            materials: [SimpleMaterial(color: .red, isMetallic: true)]
        )
        
        let inputTargetComponent = InputTargetComponent()
        let hoverComponent = HoverEffectComponent()
        
        let boxCollision = CollisionComponent(shapes: [.generateBox(size: boxSize)])

        let spinComponent = Rotation(horizontalAxis: 0, verticalAxis: 0, depthAxis: 1.0)
        
        let boxEntity = Entity()
        boxEntity.components.set([
            boxModel, boxCollision, inputTargetComponent, hoverComponent,
            spinComponent
        ])
        
        content.add(boxEntity)
        
        let camera = Entity()
        camera.components.set(PerspectiveCameraComponent())
        content.add(camera)
        
        let cameraLocation: SIMD3<Float> = [1, 1, 2]
        camera.look(at: .zero, from: cameraLocation, relativeTo: nil)
    }
    
    func spinEntity(_ entity: Entity) throws {
        guard let spinComponent = entity.components[Rotation.self]
        else { return }
        
        let spinAction = SpinAction(revolutions: 1, localAxis: spinComponent.spinAxis)
        
        let spinAnimation = try AnimationResource.makeActionAnimation(
            for: spinAction,
            duration: 1,
            bindTarget: .transform
        )
        entity.playAnimation(spinAnimation)
    }
}
