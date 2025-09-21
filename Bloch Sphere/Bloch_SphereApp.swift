//
//  Bloch_SphereApp.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import SwiftUI
import SwiftData

@main
struct Bloch_SphereApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Gate.self, Sequence.self, Matrix.self])
    }
}
