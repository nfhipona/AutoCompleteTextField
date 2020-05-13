# AutoCompleteTextField

[![CI Status](https://img.shields.io/badge/build-passed-brightgreen.svg)](https://img.shields.io/badge/build-passed-brightgreen.svg)
[![Version](https://img.shields.io/badge/pod-v0.5.0-blue.svg)](https://img.shields.io/badge/pod-v0.5.0-blue.svg)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://img.shields.io/badge/Lisence-MIT-yellow.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://img.shields.io/badge/platform-ios-lightgrey.svg)

![ezgif com-resize 1](https://cloud.githubusercontent.com/assets/6511079/16903266/0f2c58e2-4c50-11e6-827c-57b47992c9b2.gif)

## Features
- [x] Provides a subclass of UITextField that has suggestion from input
- [x] Has autocomplete input feature
- [x] Data suggestion are provided by users
- [x] Enable store smart domains
- [x] Optimized and light weight


## Requirements

- iOS 10.0+
- Xcode 11+
- Swift 5+


## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `AutoCompleteTextField` by adding it to your `Podfile`:

```ruby
pod "AutoCompleteTextField"
```

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage bootstrap`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/AutoCompleteTextField.framework` to an iOS project.

```
github "nferocious76/AutoCompleteTextField"
```

#### Manually
1. Download and drop ```/Pod/Classes```folder in your project.  
2. Congratulations!  

## Usage

```Swift

// Initializing `AutoCompleteTextField` 
let myTextField = AutoCompleteTextField(frame: CGRect(x: 20, y: 64, width: view.frame.width - 40, height: 40), dataSource: `YourDataSource`, delegate: `YourDelegate`)

// Setting `dataSource`, it can be set from the XCode IB like `TextFieldDelegate` in which will appear as `actfDataSource`
myTextField.dataSource = `YourDataSource`

// Setting delimiter (optional). If set, it will only look for suggestion after the delimiter
myTextField.setDelimiter("@")

// Show `AutoCompleteButton`
myTextField.showAutoCompleteButtonWithImage(UIImage(named: "checked"), viewMode: .whileEditing)

// Providing data source to get the suggestion from inputs
func autoCompleteTextFieldDataSource(_ autoCompleteTextField: AutoCompleteTextField) -> [ACTFWeightedDomain] {

    return weightedDomains // AutoCompleteTextField.domainNames // [ACTFDomain(text: "gmail.com", weight: 0), ACTFDomain(text: "hotmail.com", weight: 0), ACTFDomain(text: "domain.net", weight: 0)]
}

```

## ACTFDomain

`ACTFDomain` is struct type that conforms to the `Codable`. User can store and retrieve smart domains.

One example may be 'gmail.com' and 'georgetown.edu'. Users are more likely to have a 'gmail.com' account so we would want that to show up before 'georgetown.edu', even though that is out of alphabetical order.

`ACTFDomain` is sorted based on its usage.

This is just one example. Manually providing a suggestion gives more flexibility and does not force the usage of an array of strings. 

```Swift

// Usage
let g1 = ACTFDomain(text: "gmail.com", weight: 10)
let g2 = ACTFDomain(text: "googlemail.com", weight: 5)
let g3 = ACTFDomain(text: "google.com", weight: 4)
let g4 = ACTFDomain(text: "georgetown.edu", weight: 1)

let weightedDomains = [g1, g2, g3, g4] // [ACTFDomain]

// Storing

// store single
if g1.store(withKey: "Domain") {
    print("Store success")
}

// store multiple
if ACTFDomain.store(domains: weightedDomains, withKey: "Domains") {
    print("Store success")
}

// Retrieving

// retrieved single
if let domain = ACTFDomain.domain(forKey: "Domain") {
    print("Retrieved: ", domain)
}

// retrieved multiple
if let domains = ACTFDomain.domains(forKey: "Domains") {
    print("Retrieved: ", domains)
}

```

## Contribute
We would love for you to contribute to `AutoCompleteTextField`. See the [LICENSE](https://github.com/nferocious76/AutoCompleteTextField/blob/master/LICENSE) file for more info.

## Author

Neil Francis Ramirez Hipona, nferocious76@gmail.com

### About

This project was inpired by 'HTAutocompleteTextField' an Objc-C framework of the same feature.

## License

AutoCompleteTextField is available under the MIT license. See the [LICENSE](https://github.com/nferocious76/AutoCompleteTextField/blob/master/LICENSE) file for more info.
