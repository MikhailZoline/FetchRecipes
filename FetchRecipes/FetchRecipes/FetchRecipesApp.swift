//
//  FetchRecipesApp.swift
//  FetchRecipes
//
//  Created by Mikhail Zoline on 10/16/24.
//

import Combine
import SwiftUI
import Models
import Networking
import Tools

@main
struct FetchRecipesApp: App {
    var body: some Scene {
        WindowGroup {
            RecipesListView(
                viewModel: .init()
            )
        }
    }
}
