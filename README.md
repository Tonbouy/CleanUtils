# CleanUtils

[![Version](https://img.shields.io/cocoapods/v/CleanUtils.svg?style=flat)](https://cocoapods.org/pods/CleanUtils) [![License](https://img.shields.io/cocoapods/l/CleanUtils.svg?style=flat)](https://cocoapods.org/pods/CleanUtils) [![Platform](https://img.shields.io/cocoapods/p/CleanUtils.svg?style=flat)](https://cocoapods.org/pods/CleanUtils)

The need for this toolkit came from always reusing the same base classes and extensions in all projects to implement Clean Architecture with a clean usage of viewModels, dataStates

CleanUtils was mainly designed to be included in most projects which is why classes leave space for customization in extensions.

## Example

The example project is mostly for development purposes, it doesn't really show actual features of the project

Still, to run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- RxSwift
- RxCocoa

## Installation

CleanUtils is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CleanUtils'
```

# Documentation

You will find in this section a list of the classes, and how they are used in some examples

# States

All states come with a basic function called `.relay()` and with optional parameters specifying which sources can be fetched ...

Some are templated types, others are just initialised plain and contains an `Any?` object.

They are initialised this way in the viewModel. It produces a `BehaviorRelay<State>`.

## ActionState

ActionState was designed with a sole purpose: executing an action and optionally fetching some data in the meantime.

See [Basic Example](#basic-example) for more information.

Available variables:
```swift
public let response: Any? // Response object
public let loading: Bool // Sounds obvious ^^
public let error: Error? // Error object if one has happened
```

## DataState

DataState is a state that allows to load a single object. It also has the possibility to load from remote source and local source at the same time. Using the localDB of your choice, and calling the `loadRemote()` and `loadLocal()` with the according  `Observable` resulting from your data source.

It comes with some useful functions to bind the loading and the success events with CleanUITableView and CleanUICollectionView explained a bit later

See [Basic Example](#basic-example) for more information.

Available variables:
```swift
public let data: Data? // Data being a templated type you stated at init
public let localEnabled: Bool // Have you enabled a local source at init ?
public let localLoading: Bool // Is your local source still loading the data ?
public let remoteEnabled: Bool // Have you enabled a remote source at init ?
public let remoteLoading: Bool // Is your remote source still loading the data ?
public let refreshLoading: Bool // Used for refreshing the whole struct
public let error: Error? // Has any error happened during the fetch ? (that's the last happened)
```

## CollectionState

CollectionState is basically the same as DataState but with an array of objects.

The thing here, is that CollectionStates were designed to handle pagination.

See [Paged Example](#paged-example) for more information.

All variables in DataState are included in CollectionState.
Added variables:
```swift
public let paginationEnabled: Bool // Pagination can be switched off if not used
public let paginationLoading: Bool // Is a new page being loaded ?
public let currentPage: Int
public let totalPages: Int // can usually be fetched from the server reponse headers
public let totalItems: Int // can usually be fetched from the server reponse headers
```
# Pagination

## Paged

This object needs 3 type of data:
```swift
public let data: T?
public let itemsCount: Int? // Total count of items server-side
public let pagesCount: Int? // Number of pages available to request
```

It is initialised from your network return, here is an example:

```swift
let data = try Mapper<T>(context: context).mapArray(JSONString: jsonString)
let totalString = response.allHeaderFields["pagination-total-count"] as? String ?? "0"
let total = Int(totalString) ?? 0
return Paged(data: data, itemsCount: total, pagesCount: total / perPage + 1)
```

The actual implementation of `Paged` depends on your webServices and how data is returned.

## PagedCollectionController

PagedCollectionController is the data structure that will manage your processing of pages: remaining, loading, data...

Initialisation takes a closure as parameter : `(_ page: Int) -> Observable<Paged<[T]>>`
`T` being here the object type you are requesting.

Usually, this closure will be a network call, using the page number in the request parameters to load the according page.

See [Paged Example](#paged-example) for more information.

## PagedUITableView & PagedUICollectionView

Subclasses of UITableView & UICollectionView to work with the PagedCollectionController and handle pagination.

They also add a pullToRefresh on top of the view since it is natively supported by UITableView since iOS10

You can set the `loadingColor` property after init to set the refreshControl's color.

They can use classic Delegate & DataSource, but they also come with a PagedUITableViewDataSource & PagedUICollectionViewDataSource if you want them to be paged.

Those protocols are the same as UIKit's respective, they just add two functions in the protocol

```swift
	func loadMore() // Called when a new page needs to be loaded
	func refreshData() // Serves to reload the whole table/collectionView on pullToRefresh
```

NOTE: the `loadMore()` triggers on `dequeueReusableCell()` when the UI reaches the 5 last items of the table/collectionView. So when you instantiate your cells remember to register them in the tableView and dequeue them as reusable, otherwise pagination won't work.

They basically work the same way.

See [Paged Example](#paged-example) for more information.

# CleanViewModel

This is the base viewModel class from which all viewModels should inherit.
It contains simple but useful elements such as : 
- Input/Output Management
- DisposeBag (RxSwift)

How does the class work exactly and how to declare one... Well, let's jump to examples, it's actually very simple !

<a name="basic-example">

## Basic Example

</a>

Let's say you have a ProfileViewController, where you can add a user as friend, declaring a CleanViewModel would look like this :

```swift
enum ProfileInput {
	case addUserTapped
}

enum ProfileOutput {
	case userAdded
}

class ProfileViewModel: CleanViewModel<ProfileInput, ProfileOutput> {

	let userState = DataState<User>.relay(remoteEnabled: true)
	let addState = ActionState.relay(remoteEnabled: true)
	let userInteractor: UserInteractor // Clean Architecture :)

	var user: User? {
		return userState.value.data as? User
	}

	override init() {
		userInteractor = UserInteractor() // Clean Architecture :)
		super.init()

		// Load process works with loadRemote & loadLocal, applies to all kinds of State
		// Here launched on init, but can also be triggered in the perform, doesn't matter
		userInteractor
			.fetchUser() // This is basically a RxSwift.Observable
			.loadRemote(with: userState) // This loads data into the state
			.disposed(by: self)
	}
	
	override func perform(_ input: ProfileInput) {
		switch input {
		case .addUserTapped:
		// Load process with only success handled, works only for ActionState
		// this one's disposal is handled in background
		//
		// You can also use the executeAction with only addState as parameter and handle both 	
		// success and error by subscribing to addState in your ViewController.
			userInteractor
				.addUser() // Again, a RxSwift.Observable
				.executeAction(with: addState, 
							   viewModel: self, 
							   success: .userAdded)
		}
	}
}
```

Then, on the viewController's side, all you have to do to get the output back is :

```swift
class ProfileViewController: UIViewController {
	@IBOutlet weak var addButton: UIButton!

	let viewModel = ProfileViewModel()
	var disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		viewModel
			.userState
			.subscribe(onNext: { [unowned self] state in
				if state.isGlobalLoading {
					return // Data is still loading
				}
				if let user = viewModel.user {
					self.updateView(forUser: user) // Data was fetched and mapped successfully
				} else {
					// Could not fetch data
				}
			})
			.disposed(by: self.disposeBag)
		
		viewModel
			.subscribe(onOutput: { output in
				switch output {
					case .userAdded:
						print("User has been added successfully")
				}
			})
			.disposed(by: self.disposeBag)

		addButton
			.rx.tap.mapTo(ProfileInput.addUserTapped)
			.bind(to: self.viewModel)
			.disposed(by: self.disposeBag)
	}
}
```

<a name="paged-example">

## Paged example

</a>
Let's say you have a MessagesViewController, where you need to display a paged list of messages, declaring a CleanViewModel would look like this :

```swift
enum MessagesInput {
	case refreshData
	case loadMore
}

enum MessagesOutput {
}

class MessagesViewModel: CleanViewModel<MessagesInput, MessagesOutput> {

	let messagesInteractor: MessagesInteractor // Clean Architecture :)
	lazy var pagedController = PagedCollectionController<Message> { [unowned self] page in
		return self.messagesInteractor.getMessages(forPage: page)
	}

	var messagesState: BehaviorRelay<CollectionState<Message>> {
		return pagedController.relay
	}

	var messages: [Message] {
		return messagesState.value.data ?? []
	}

	override init() {
		messagesInteractor = MessagesInteractor() // Clean Architecture :)
		super.init()
	}
	
	override func perform(_ input: ProfileInput) {
		switch input {
			case .loadMore:
				pagedController.loadMore()
			case .refreshData:
				pagedController.refreshData()
		}
	}
}
```

Then, on the viewController's side :

```swift
class MessagesViewController: UIViewController {
	@IBOutlet weak var tableView: PagedUITableView!

	let viewModel = MessagesViewModel()
	var disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.dataSource = self

		self.viewModel
			.messagesState
			.bindToPagedTableView(self.tableView)
			.disposed(by: self.disposeBag)

		self.viewModel.perform(.refreshData)
	}
}

extension ProfileViewController: PagedUITableViewDataSource {
	// don't forget the required function to conform to UITableViewDataSource
	// such as for example:

	func numberOfSections(in tableView: UITableView) {
		return viewModel.messages
	}

	// and add the two extras from PagedUITableViewDataSource

	func loadMore() {
		self.viewModel.perform(.loadMore)
	}

	func refreshData() {
		self.viewModel.perform(.refreshData)
	}
}
```

And you're all set, everytime the tableView/collectionView will reach its 5 last items, it will trigger the next page's request.

## Authors

'Tonbouy', Nico Ribeiro, nicolas.ribeiroteixeira@gmail.com

Special Thanks to 'ndmt', Nicolas Dumont, without who this could never have existed.

## License

CleanUtils is available under the MIT license. See the LICENSE file for more info.