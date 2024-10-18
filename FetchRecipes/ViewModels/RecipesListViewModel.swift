//
//  RecipesListViewModel.swift
//  FetchRecipes
//
//  Created by Mikhail Zoline on 10/16/24.
//

import Combine
import SwiftUI
import StateManagement
import Models
import Networking

/// Note: RecipesListViewModel is a struct/value type, but we need to mutate [recipes] upon the recipesPublisher/Loader receiveValue
/// Thanks to the ViewModelWrapper in StateManagement, the array of recipes is observable and percived as published from SwiftUI views
/// XxxViewModels are value types that act like a reference type
/// XxxViewModels do not need to conform to ObservableObject to be visible/mutable in/from SwiftUI views
public struct RecipesList {
    
    public typealias ViewModel = StateManagement.ViewModelWrapper<ObservableItems, Action>
    
    public typealias responseType = [String: [Models.RecipeShape]]
    
    public struct ObservableItems {
        var recipes: [Recipe.ViewModel] = [Recipe.ViewModel]()
        var networkingError: Networking.NetworkingError? = nil
        var scrollToTop: Bool = false
    }
    
    public enum Action {
        case reload(requestType: Networking.RequestType)
    }
    
}

extension RecipesList.ViewModel {
    
    convenience init() {
        Networking.recipeModelPublisher.send(.success(Networking.demoData ?? []))
        let url: URL = Networking.url(for: .allRecipes) ?? .init(fileURLWithPath: "")
        Networking.loadRequest(with: url)
        self.init(
            observableItems: .init(),
            actionPublisher: PassthroughSubject<RecipesList.Action, Never>()
        )
        Networking.recipeModelPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in }
            receiveValue: { [weak self] in
                guard let self else { return }
            switch $0 { 
                case .success(let response):
                self.observableItems.networkingError = nil
                self.observableItems.recipes = response
                if response.isEmpty {
                    self.observableItems.networkingError = Networking.NetworkingError(.emptyData(error: URLError(.zeroByteResource)))
                } else {
                    self.observableItems.scrollToTop.toggle()
                }
                case .failure(let error):
                    self.observableItems.networkingError = error
            }
        }.store(in: &cancellables)
        
        self.actionPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                switch $0 {
                    case .reload(let requestType):
                    Networking.loadRequest(with: Networking.url(for: requestType) ?? .init(fileURLWithPath: ""))
                }
        }
        .store(in: &cancellables)
    }
}
    
extension RecipesList.ViewModel {
    public func sendReloadAction( requestType: Networking.RequestType) {
        self.actionPublisher.send(.reload(requestType: requestType))
    }
}

public extension RecipesList.ViewModel {
    static var url: URL = Networking.url(for: .demoData) ?? .init(fileURLWithPath: "")
    static var demo: RecipesList.ViewModel = .init()
}

