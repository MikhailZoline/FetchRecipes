//
//  RecipesListView.swift
//  FetchRecipes
//
//  Created by Mikhail Zoline on 10/16/24.
//

import SwiftUI
import Models
import Networking

public enum RecipesContainerView {
    static let containerCornerRadius: CGFloat = 24
}

struct RecipesListView: View {
    
    @ObservedObject var viewModel: RecipesList.ViewModel
    
    @State var recipesContainerFrame: CGRect = .zero
    
    @State var cuisine: String = ""
    
    @State private var scrollViewID = UUID()
    
    var recipesStack: some View {
        ScrollView {
            LazyVStack(alignment: .center) {
                
                ForEach(Array(viewModel.recipes.enumerated()), id: \.offset) { (_, recipe) in
                    RecipeCellView(viewModel: recipe, cellFrame: $recipesContainerFrame)
                        .onAppear {
                            if cuisine != recipe.cuisine && viewModel.recipes.count != 0 {
                                cuisine = recipe.cuisine
                            }
                        }
                }
            }
            .errorAlert(Binding<Networking.NetworkingError?>.constant(viewModel.networkingError))
            .onChange(of: viewModel.recipes.count, perform: {
                if $0 == 0 {
                    cuisine = "Empty"
                }
            })
            .onChange(of: viewModel.scrollToTop) { _ in
                withAnimation {
                    self.scrollViewID = UUID()
                }
            }
        }
        .id(self.scrollViewID)
    }
    
    var recipesContainer: some View {
        VStack(spacing: 4){
            buttonsBar
                .frame(width: recipesContainerFrame.width, height: 44)
                .bordered(
                    cornerRadius: RecipesContainerView.containerCornerRadius,
                    cornerStyle: .circular
                )
            Spacer()
            Text(verbatim: "Cuisine \(cuisine)")
                .frame(width: recipesContainerFrame.width, height: 44)
                .bordered(
                    cornerRadius: RecipesContainerView.containerCornerRadius * 0.5,
                    cornerStyle: .continuous
                )
            Spacer()
            recipesStack
        }
        .readFrame(frame: $recipesContainerFrame, space: .global)
        .padding(.top, RecipesContainerView.containerCornerRadius)
        .padding(.bottom)
        .padding(.horizontal, 24)
        .background(Color.white)
        .cornerRadius(RecipesContainerView.containerCornerRadius)
    }
    
    var buttonsBar: some View {
        HStack {
            Button(
                action: { viewModel.sendReloadAction(requestType: .allRecipes) }
            ) {
                Label("Reload Current", systemImage: "arrow.circlepath")
            }
            
            Divider()
                .tint(.red)
                .foregroundColor(.green)
            
            Button(
                action: { viewModel.sendReloadAction(requestType: .emptyData) }
            ) {
                Label("Load Empty", systemImage: "arrow.circlepath")
            }
            
            Divider()
                .tint(.red)
                .foregroundColor(.green)
            
            Button(
                action: { viewModel.sendReloadAction(requestType: .malformedData) }
            ) {
                Label("Load Malformed", systemImage: "arrow.circlepath")
            }
        }
    }
    
    var body: some View {
        recipesContainer
    }
}

#Preview {
    RecipesListView(viewModel: .demo)
}
