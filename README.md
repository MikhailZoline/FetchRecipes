## FetchRecipes is a showcase App of MVVM using SwiftUI/Combine
# The application architecture is based on CLEAN principles and architectural patterns such as MVVM. The UI and buisness logic implemented with SwiftUI, Combine and Swift

## The UI layer is isolated from business logic in the View folder at the Application level. UI related buisness logic is living in the ViewModels folder at the Application level. 

## The API consumption, Response Handling and Model Shaping are isolated into corresponding Networking, State Managment, Models, and Tools Packages at the submodule/Package level.

## To avoid potential issues of maintability/imported bugs/malware backdoors, etc. the application does not depend on any third party frameworks. The frameworks living in the Package layer are easier to maintain/upgrade without affecting the core logic. By organizing the code into layers, the Application can adapt to changes more easily, and maintenance becomes less cumbersome.

# The Modules layer: there are four packages that build with SPM.

## The Networking package is responsible for execution of REST API requests and handling the responses back to the App. Receiving and Handling API responses and Model parsing to the ViewModel layer are implemented using Combine's Publisher-Subscriber pattern.

## The Models package is responsible for abstraction of model objects and implementation of serialization/de-serialisation from the API responses. The main structure of Models module is the Recipe Model (an abstration of food recipe). The Recipe Model hold all information about a particular recipe. The intent of the Recipe Model is obviously to convey the recipes' data to the SwiftUI views. A Recipe Model is created/wrapped with View Model Wrapper to convert a Recipe struct into an Observable Object with the help of the State Managment package.

## The State Managment package is generalizing Models structures into ObservableObjects so they could be visible/mutable from SwiftUI views. The State Managment package allows to wrap any value based structure into an Observable Object. By default value based structures are not accepted by SwiftUI Views as observable objects i.e only classes are allowed to adopt @Observable Object protocol (SwiftUI 5, with the Observation frameworks does not solve that issue)

## The Tools package contains all helper methods structures that are mostly SwiftUI View accessoires/enhancements  

# The App Layer
## The main part of the App lives in RecipesListView.swift and RecipesListViewModel.swift. The RecipesListViewModel is designed to gather a set of recipes into Swift collection which could be visited in the View's body method for rendering.

## The RecipesListView is rendering a list of recipes via LazyVStack embedded into scroll (which is recommended by Apple for large collections of dynamic cells). Every cell of the VStack is redered with the RecipeCellView by passing a RecipeViewModel along.
