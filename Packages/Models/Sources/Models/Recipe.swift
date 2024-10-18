//
//  A data model for a recipe and its metadata.
//  Models
//
//  Created by Mikhail Zoline on 10/16/24.
//

import Combine
import SwiftUI
import StateManagement

public struct RecipeShape: Codable {
    public var uuid: String?
    public var name: String
    public var cuisine: String
    public var photo_url_large: String
    public var photo_url_small: String
    public var source_url: String?
    public var youtube_url: String?
     /// Serialise to Recipe ViewModel from Json representation
    public var toViewModel: Recipe.ViewModel {
        return .init(recipeShape: self)
    }
}

public struct Recipe {
    public typealias ViewModel = StateManagement.ViewModelWrapper<ObservableItems, Action>
    public struct ObservableItems {
        public var name: String
        public var cuisine: String
        public var photoUrl: URL?
        public var thumbnailUrl: URL?
        public var sourceUrl: URL?
        public var youtubeUrl: URL?
        
        public init(
            name: String,
            cuisine: String,
            photoUrl: URL? = nil,
            thumbnailUrl: URL? = nil,
            sourceUrl: URL? = nil,
            youtubeUrl: URL? = nil
        ) {
            self.name = name
            self.cuisine = cuisine
            self.photoUrl = photoUrl
            self.thumbnailUrl = thumbnailUrl
            self.sourceUrl = sourceUrl
            self.youtubeUrl = youtubeUrl
        }
        
    }
    
    public enum Action {
    }
    
}

public extension Recipe.ViewModel {
    convenience init(recipeShape: RecipeShape) {
        self.init(
            observableItems: .init(
                name: recipeShape.name,
                cuisine: recipeShape.cuisine,
                photoUrl: URL(string: recipeShape.photo_url_large),
                thumbnailUrl: URL(string: recipeShape.photo_url_small),
                sourceUrl: URL(string: recipeShape.source_url ?? ""),
                youtubeUrl: URL(string: recipeShape.youtube_url ?? "")
            ),
            actionPublisher: PassthroughSubject<Recipe.Action, Never>()
        )
    }
}

public extension Recipe.ViewModel {
    static var mock: Recipe.ViewModel {
        .init(
            observableItems: .init(
                name: "Pumpkin Pie",
                cuisine: "American",
                photoUrl: URL(
                    string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/93e50ff1-bf1d-4f88-8978-e18e01d3231d/large.jpg"
                ),
                thumbnailUrl: URL(
                    string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/93e50ff1-bf1d-4f88-8978-e18e01d3231d/small.jpg"
                ),
                sourceUrl: URL(
                    string: "https://www.bbcgoodfood.com/recipes/1742633/pumpkin-pie"
                ),
                youtubeUrl:  URL(
                    string: "https://www.youtube.com/watch?v=hpapqEeb36k"
                )
            )
        )
    }
}

