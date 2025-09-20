//
//  MTMathUILabelRepresentable.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

import SwiftUI
import AppKit
import SwiftMath

struct MTMathUILabelRepresentable: NSViewRepresentable {
    @Binding var latex: String
    
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MTMathUILabelRepresentable
        unowned var label: MTMathUILabel!
        
        init(parent: MTMathUILabelRepresentable) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeNSView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.textColor = .white
        context.coordinator.label = label
        return label
    }
    
    func updateNSView(_ label: MTMathUILabel, context: Context) {
        if label.latex != latex {
            label.latex = latex
        }
    }
}
