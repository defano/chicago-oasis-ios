# Chicago Oasis for iOS

A fully-native Swift implementation of the Chicago Oasis project for iOS devices. This "universal" app runs on both iPhones and iPads (including full-screen on iPhone X) where it pulls business accessibility and socioeconomic data from the Chicago Oasis web app and renders it using Apple's MapKit.

<img src="https://github.com/defano/chicago-oasis-ios/blob/master/Release%20Assets/hero.jpg" width=350/>

Available on the [iTunes App Store](https://itunes.apple.com/us/app/chicago-oasis/id1115492310).

### Related Projects

* [Chicago Oasis Data](https://github.com/defano/chicago-oasis-data) - The data analysis scripts (written in Python) that pull down and analyze source data from the City of Chicago and US Census Bureau. Based on Ben Galewsky's original [Apache Pig implementation](https://github.com/BenGalewsky/oasis).
* [Chicago Oasis](https://github.com/defano/chicago-oasis) - The web front-end and server infrastructure responsible for serving analysis files to visualization clients like this.

## Features

* Shows how close residents live to businesses of every licensed type for every neighborhood and census tract in Chicago
* Mixes sociographic information (including income and unemployment rates) for all 77 city neighborhoods
* Finds "critical businesses," that is, those whose dissapearance would create a business desert
* Visualizes business accessibility across the city as a whole, or within the area visible on the map ("relative shading")
* Renders data across time (over twenty years worth, in some cases)

## Building

This project was created in XCode 9.2 and written in Swift 4. Your mileage may vary with other versions. To build the app locally,

1. Clone this repository
```
$ git clone https://github.com/defano/chicago-oasis-ios.git
```
2. Open the project workspace (`Chicago Oasis.xcworspace`) in XCode. Note that this project uses CocoaPods; if you open the project file (`Chicago Oasis.xcodeproj`) instead of the workspace, third party dependencies imported through CocoaPods will not be visible to XCode and the project will not build.

#### Updating Dependencies

This project uses CocoaPods for dependency management. To modify these dependencies:

1. Assure that CocoaPods is installed on your machine
```
$ sudo gem install cocoapods
```
2. In the root of the Chicago Oasis project, modify the `Podfile` as needed, then execute
```
$ pod update
```
Or, if you added or removed dependencies,
```
$ pod install
```
3. Finally, clean and rebuild the project from within XCode.
