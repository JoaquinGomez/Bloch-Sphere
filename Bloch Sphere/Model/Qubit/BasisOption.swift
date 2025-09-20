//
//  BasisOption.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/20/25.
//

enum BasisOption {
    case computational
    case hadamard
    case pauliY
    
    func values() -> Basis {
        switch self {
        case .computational:
            return Basis(name: "Computational", firstSate: "|0\\rangle", secondState: "|1\\rangle")
        case .hadamard:
            return Basis(name: "Hadamard", firstSate: "|+\\rangle", secondState: "|-\\rangle")
        case .pauliY:
            return Basis(name: "Pauli Y", firstSate: "|i\\rangle", secondState: "|-i\\rangle")
        }
    }
}
