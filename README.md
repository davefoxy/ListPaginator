# ListPaginator

[![Version](https://img.shields.io/cocoapods/v/ListPaginator.svg?style=flat)](https://cocoapods.org/pods/ListPaginator)
[![License](https://img.shields.io/cocoapods/l/ListPaginator.svg?style=flat)](https://cocoapods.org/pods/ListPaginator)
[![Platform](https://img.shields.io/cocoapods/p/ListPaginator.svg?style=flat)](https://cocoapods.org/pods/ListPaginator)

ListPaginator simplifies the fetching and state management for lists of data populated from a paginated endpoint. Its main aims are to maintain correct page offsets, fetch statuses and retain responses from paginated API endpoints.

It's fully documented so if any properties aren't making sense, please make sure to [read the docs!](). 

## Usage

> TL;DR: Check out the sample application contained within and just copy/paste it 😉

### Preparing Datasources and ListPaginator's Configuration

ListPaginator requires the following information to work correctly...

- A way to fetch data given the current page or item offset.
- The response and item types your endpoint vends and where within the response each item can be found.
- The paging strategy your endpoint uses. Specifically, whether new pages and fetched by passing a current page number or item offset.

To provide this, let's take the following response of a screen displaying a list of `Product`s in a `Shop` as an example:

```swift
struct Shop: Decodable {
    let products: [Product] // This is our paginated content
}

struct Product: Decodable {
    let productName: String
}
```

Our imaginary API endpoint manages pagination by taking an incrementing page index.

We instantiate ListPaginator, informing it of the root `Shop` response type and the individual item types (in this case, `Product`) and which property within `Shop` to find our `Product`s like so:

```swift
let paginator = ListPaginator<Shop, Product>(strategy: .pageIndex(startingFrom: 1), responseItemsKeyPath: \.products)
```

Next, we inform ListPaginator how to fetch its data by assigning the `requestProvider` property. You can use either a Combine publisher or a simple Swift closure like so:

```swift
paginator.requestProvider = .closure({ page, completion in
    ProductsRequest(page: page).performRequest(completion: completion)
})
```

### Populating SwiftUI Views and Table/Collection Views

Your data is accessible via ListPaginator's `results: [Item]` array. It uses generics to vend items in the object type defined during instantiation. A UIKit application's table/collection view datasource methods can return its `count` and objects for configuration. SwiftUI applications can iterate over it in a number of different ways such as via a `ForEach`, a `List` backing store etc.

### Fetching New Pages

When the user scrolls near the end of your content, trigger the paginator's `fetchMoreIfNeeded` publisher either via a Combine operation or directly by calling `paginator.fetchmoreIfNeeded.send()`. Check out the following example application for how this can be achieved in either a SwiftUI or UIKit-driven application.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
The demo application shows usage for both Combine/SwiftUI and UIKit-based applications. 

## Installation

### Cocoapods

ListPaginator is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ListPaginator'
```

### Swift Package Manager (SPM)

You can integrate ListPaginator via SPM. Within Xcode, choose "File" -> "Swift Packages" -> "Add Package Dependency" and paste in this repo's URL: https://github.com/davefoxy/ListPaginator

## Author

[David Fox](https://github.com/davefoxy/)


## License

ListPaginator is available under the MIT license. See the LICENSE file for more info.
