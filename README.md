## FetchRecipes
# The Application is deigned upon MVVM pattern using Combine and SwiftUI

For reasons of modularity, scalability, testability and reusability, the application uses Swift modules living in the Packages folder.
I didn't use any of third party modules because firstly its really not nesessary to this day to use freely available APIs since all required functionnalities are availabe from native APIs. Then if you use any of them there is a danger of importing other peopls bugs finally for the reason of maintability there is a danger that some of those APIs wont be supported in the future versions of iOS.   

There are four packages that build with SPM.

# The Networking package is responsible for execution of REST API requests and handling the responses back to the App.

# The Models package is responsible for abstraction of model objects
and implementation of serialization/de-serialisation from REST API responses.
The main object of Models module is Recipe. ViewModel struct which hold all information about a particular recipe. The intent of the Recipe. ViewModel is obviously to convey the recipes' data to the SwiftUI views.

## The Recipe.ViewModel object created/wrapped with ViewModelWrapper to convert a recipe struct into an Observable Object.
## The helper object in Models module is the Recipe Shape struct which is used to shape JSON described data into Recipe. ViewModel struct.

# The StateManagment package is responsible for generalization of Model Struct so they are being visible/mutable from SwiftUI views

## The Tools package contains all helper methods, structs/classes

### The main part of the App lives in RecipesListView and Recipes List.ViewModel
On the app side the struct of Recipes List. ViewModel is designed to assemble a collection of recipes. ViewModels into an array and parse that array to the corresponding SwiftUI RecipesListView for rendering.

## The RecipesListView is rendering a list of recipes via LazyVStack embedded into scroll (which is recommended by Apple for large collections of dynamic cells). Every cell of the VStack is redered with the RecipeCellView by passing a Recipe.ViewModel along.

### The intention of the app is to demonstrate the loading/reloading of three lists of recipes, i.e. AllRecipes(default behavior), EmptyRecipes and Malformed Data. 
The list of recipes is sorted upon serialisation by cusine in alphabetic order. 
The field of cusine is rendered at the top of the scroll and changes dynamically upon cusine of the recipes on the screen 
When reloading All Recipes the content is scrolled to the back to the top automatically to show the refreshing of the data.

The automatic tests are implemented only in Networking module, with Networking Tests target, to demonstrate my understanding of unit testing.
The automatic tests could use more coverage as to be expanded into other modules too.

The cashing of Remote Image is implemented in Tools module but it's usage is commented out in RecipeCellView L:24, since it gives partially rendered images and I dont have much time to dive into debugging.
The behaviour of RemoteImage is a subject to improvement from point of view of cashing.

In Tools StickyHeaderScrollView Preview there is just an idea of usage of swiftUI techniques to render a sticky header over scroll view.

