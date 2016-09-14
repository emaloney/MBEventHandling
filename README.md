![Gilt Tech logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/gilt-tech-logo.png)

# Mockingbird Event Handling Module

The Mockingbird Event Handling Module adds to [the Mockingbird Data Environment](https://github.com/emaloney/MBDataEnvironment) the ability to create *listeners* for `NSNotification` events and perform  *actions* in response to specific events.

If you wish to use a dependency manager, [Carthage](https://github.com/Carthage/Carthage) is supported. Just add the following line to your `Cartfile`, then run `carthage update`:

```
github "emaloney/MBEventHandling" ~> 2.0.0  
```

Otherwise, you may embed `MBEventHandling.xcodeproj` (along with the necessary dependencies) within your own project and link against the appropriate frameworks for your target platform.
