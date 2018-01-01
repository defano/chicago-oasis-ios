# Chicago Oasis for iOS

Download from the [iTunes App Store](https://itunes.apple.com/us/app/chicago-oasis/id1115492310).

![Screenshot](https://github.com/defano/chicago-oasis-ios/blob/master/Release%20Assets/Screen%20Shots/iPad/12.9%20inch/bedbreakfast-by-census.png)

A fully-native Swift implementation of the Chicago Oasis project for iOS devices. This "universal" app runs on both iPhones and iPads (including full-screen on iPhone X) pulls demographic, critical business, and accessibility data from the http://chicago-oasis.org website and renders it using Apple's MapKit.

See the [Chicago Oasis project](https://github.com/defano/chicago-oasis) for a general overview of the project and details about how the data was generated.

## Features

* Shows how close residents live to businesses of every licensed type for every neighborhood and census tract in Chicago
* Mixes sociographic information (including income and unemployment rates) for all 77 city neighborhoods
* Finds "critical businesses," that is, those whose dissapearance would create a business desert
* Visualizes business accessibility across the city as a whole, or within the area visible on the map ("relative shading")
* Renders data across time (up to twenty years)

## Building

Build and run this project in XCode 9 using Swift 4; your mileage may vary with other versions:

1. Clone this repository
```
$ git clone https://github.com/defano/chicago-oasis-ios.git
```
2. Open XCode and open the project workspace (`Chicago Oasis.xcworspace`).

If you open the `Chicago Oasis.xcodeproj` file instead of the workspace third party dependencies imported through CocoaPods will not be visible to XCode.

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
3. Clean and rebuild the project from within XCode.
