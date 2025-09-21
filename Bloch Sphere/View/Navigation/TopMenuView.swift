//
//  MasterView.swift
//  Bloch Sphere
//
//  Created by JOAQUIN ENRIQUE GOMEZ LOPEZ on 9/19/25.
//

import SwiftUI
import SwiftData

struct TopMenuView: View {
    @Binding var selectedMenuOption: MenuOption
    private let items = MenuOption.allCases

    var body: some View {
        List(items, id: \.self, selection: $selectedMenuOption) { item in
            Text(item.rawValue)
                .onTapGesture {
                    selectedMenuOption = item
                }
        }
        .navigationTitle("Bloch Sphere")
    }
}
