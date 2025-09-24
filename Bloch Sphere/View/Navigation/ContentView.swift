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
                viewModel.createGameScene(content)
            }
            .realityViewCameraControls(.orbit)
        }
    }
}
