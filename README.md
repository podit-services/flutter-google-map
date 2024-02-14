# Flutter Google Map

A simple flutter app which uses google map to show user location.

## Build Steps

### Android

1. Set the `minSdkVersion` in `android/app/build.gradle`:

   ```
   android {
       defaultConfig {
           minSdkVersion 20
       }
   }
   ```
2. Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

   ```
   <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR KEY HERE"/>
   ```
3. Create .env file and add your key

   ```
   GOOGLE_MAP_API_KEY="YOUR KEY HERE"
   ```

### iOS

* To set up, specify  your API key in the application delegate `ios/Runner/AppDelegate.swift` :

```
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Features

* Show user location on the map.
* Demonstrate google maps autocomplete functionality.
* Display path between two location.
