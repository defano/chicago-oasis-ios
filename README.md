# Chicago Oasis for iOS

Available for download on the [iTunes App Store](https://itunes.apple.com/us/genre/ios/id36?mt=8) soon.

A fully-native Swift implementation of the Chicago Oasis project for iOS devices. This "universal" app (runs on both iPhones and iPads)
pulls demographic, critical business, and accessibility data from the http://chicago-oasis.org web site and renders it using Apple's MapKit.

See the Chicago Oasis project for a general overview of the project and details about how the data was generated.

### Building

Build and run this project in XCode (v7.3 at the time of this writing; your milage may vary with other versions)

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
