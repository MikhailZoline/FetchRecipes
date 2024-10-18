//
//  File.swift
//  StateManagement
//  Inspired by: https://www.swiftjectivec.com/Observing-Structs-SwiftUI/
//  Created by Mikhail Zoline on 10/16/24.
//

import Combine
@dynamicMemberLookup
public class ViewModelWrapper<ObservableItems, Action>: ObservableObject {
    @Published public var observableItems: ObservableItems
    /// A `PassthroughSubject` binded to the current ViewModel
    /// Used to publish actions i.e. signals or notificatios to report to/from (both ways) the Model layer
    /// Model Layer have to subcribe to the ViewModel's actionPublisher to listen for notifs
    public let actionPublisher: PassthroughSubject<Action, Never>
    /// A set of `AnyCancellable` to store and manage the lifetime of subscribers.
    public var cancellables = Set<AnyCancellable>()
    
    /// Initializes a new ViewModelWrapper instance.
    /// - Parameters:
    ///   - observableItems: The observable value(s) to be used in the ViewModel.
    ///   - actionPublisher: A `PassthroughSubject` used to publish actions.
    public init(
        observableItems: ObservableItems,
        actionPublisher: PassthroughSubject<Action, Never> = .init()
    ) {
        self.observableItems = observableItems
        self.actionPublisher = actionPublisher
    }
    
    /// Provides access to observable values through subscripting.
    public  subscript<T>(dynamicMember keyPath: KeyPath<ObservableItems, T>) -> T {
        observableItems[keyPath: keyPath]
    }
}

/// An extension of ViewModel class providing methods for routing and binding actions.
public extension ViewModelWrapper {
    @discardableResult
    /// Binds the actions emitted by the `actionPublisher` to the specified `listener` closure.
    /// - Parameter listener: The closure that handles the `Action` objects emitted by the `actionPublisher`.
    /// - Returns: `self`
    func bind(actions listener: @escaping (Action) -> Void) -> Self {
        actionPublisher
            .sink(receiveValue: listener)
            .store(in: &cancellables)
        return self
    }
}
