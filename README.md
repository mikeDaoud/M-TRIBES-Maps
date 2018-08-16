# M-Tribes Maps

NOTE: To run the app on a device, change the bundle ID

### App features

 - App consumes a simple webservice to fetch a list of cars locations.
 - If the Api request failed, app tries to get the cars list persisted in a simple SQLite database.
 - If Api succeeded, the SQLite table is updated.
 - A maps view and a list observe the fetched list to show the locations on the map and the list.
 - The list is searchable and changes its binding to either the filtered or the full list.
 - Tapping on a car from map or from list, hides all other cars, shows an info window with the car name on it and replaces the list with more details on the car.
 - Tapping again on the selected car (or anywhere else in the map), unselects the selected cars and shows all other cars again.

### Third party Frameworks used

- [Google Maps SDK](https://cloud.google.com/maps-platform/maps/ "Google Maps SDK")
- [Alamofire](https://github.com/Alamofire/Alamofire "Alamofire"): For NSURLSession tasks abstraction
- [Pulley ](https://github.com/52inc/Pulley "Pulley "): A UI library to imitate iOS 10 maps drawer view.
- [SQLite.swift](https://github.com/stephencelis/SQLite.swift "SQLite.swift"): A Type-safe abstraction layer over SQLite in Swift
- [RxSwift](https://github.com/ReactiveX/RxSwift "RxSwift"): For declarative reactive programming along with [RxCocoa](https://github.com/ReactiveX/RxSwift/tree/master/RxCocoa) for UI components binding
