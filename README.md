![HBC Digital logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/hbc-digital-logo.png)     
![Gilt Tech logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/gilt-tech-logo.png)

# MBEventHandling

The Mockingbird Event Handling Module adds to [the Mockingbird Data Environment](https://github.com/emaloney/MBDataEnvironment) the ability to create *listeners* for `NSNotification` events and perform  *actions* in response to specific events.

MBEventHandling is part of the Mockingbird Library from [Gilt Tech](http://tech.gilt.com).


### Xcode compatibility

This is the `master` branch. It **requires Xcode 8.3** to compile.


#### Current status

Branch|Build status
--------|------------------------
[`master`](https://github.com/emaloney/MBEventHandling)|[![Build status: master branch](https://travis-ci.org/emaloney/MBEventHandling.svg?branch=master)](https://travis-ci.org/emaloney/MBEventHandling)


### License

MBEventHandling is distributed under [the MIT license](https://github.com/emaloney/MBEventHandling/blob/master/LICENSE).

MBEventHandling is provided for your use—free-of-charge—on an as-is basis. We make no guarantees, promises or apologies. *Caveat developer.*


### Adding MBEventHandling to your project

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

The simplest way to integrate MBEventHandling is with the [Carthage](https://github.com/Carthage/Carthage) dependency manager.

First, add this line to your [`Cartfile`](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "emaloney/MBEventHandling" ~> 0.0.0
```

Then, use the `carthage` command to [update your dependencies](https://github.com/Carthage/Carthage#upgrading-frameworks).

Finally, you’ll need to [integrate MBEventHandling into your project](https://github.com/emaloney/MBEventHandling/blob/master/INTEGRATION.md) in order to use [the API](https://rawgit.com/emaloney/MBEventHandling/master/Documentation/API/index.html) it provides.

Once successfully integrated, just add the following `import` statement to any Swift file where you want to use MBEventHandling:

```swift
import MBEventHandling
```

See [the Integration document](https://github.com/emaloney/MBEventHandling/blob/master/INTEGRATION.md) for additional details on integrating MBEventHandling into your project.

### API documentation

For detailed information on using MBEventHandling, [API documentation](https://rawgit.com/emaloney/MBEventHandling/master/Documentation/API/index.html) is available.


## About

Over the years, Gilt Groupe has used and refined Mockingbird Library as the base for its various Apple Platform projects.

Mockingbird began life as AppFramework, created by Jesse Boyes.

AppFramework found a home at Gilt Groupe and eventually became Mockingbird Library.

In recent years, Mockingbird Library has been developed and maintained by Evan Maloney.


### Acknowledgements

API documentation is generated using [appledoc](http://gentlebytes.com/appledoc/) from [Gentle Bytes](http://gentlebytes.com/).
