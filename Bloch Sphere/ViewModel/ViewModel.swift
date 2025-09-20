//
//  ViewModel.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import SwiftUI

@Observable
public class ViewModel {
    var selectedMenuOption: MenuOption
    var basisOption: BasisOption
    var qubit: Qubit
    
    init(selectedMenuOption: MenuOption = MenuOption.qubitState, basisOption: BasisOption = BasisOption.computational) {
        self.selectedMenuOption = selectedMenuOption
        self.basisOption = basisOption
        self.qubit = Qubit(basis: basisOption, alphaReal: "1/sqrt(2)", betaReal: "1/sqrt(2)")
    }
    
    func applyGates(_ gates: [Gate]) {
        print("Applying gates: \(gates)")
    }
}
