# State Management (iOS 17+)

## @State or @Bindable — NOT @StateObject

### ✅ Modern Pattern
```swift
struct ProfileView: View {
	@SwiftUI.State
	private var model: UserProfileModel
	
	init(_ model: UserProfileModel) {
		self._model = State(wrappedValue: model)
	}

	var body: some View {
		TextField("Name", text: $model.name)
	}
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use @StateObject with @Observable
@StateObject
private var model: UserProfileModel = .init()
```

## @Bindable — NOT @ObservedObject

### ✅ Modern Pattern
```swift
struct ProfileEditView: View {
	@Bindable
	private var model: UserProfileModel
	
	init(_ model: UserProfileModel) {
		self._model = Bindable(wrappedValue: model)
	}

	var body: some View {
		Form {
			TextField("Name", text: $model.name)
			TextField("Email", text: $model.email)
		}
	}
}

// Usage
struct ProfileView: View {
	@Bindable
	private var model: UserProfileModel
	
	init(_ model: UserProfileModel) {
		self._model = Bindable(wrappedValue: model)
	}

	var body: some View {
		ProfileEditView(model)
	}
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use @ObservedObject with @Observable
@ObservedObject
var model: UserProfileModel
```

## Common Patterns

### Navigation with Observable
```swift
@Observable
class NavigationModel {
	var path = NavigationPath()
	var selectedItem: Item?

	func navigateTo(_ item: Item) {
		selectedItem = item
	}
}

struct ContentView: View {
	@SwiftUI.Bindable
	private var navigation: NavigationModel

	init(_ model: UserProfileModel) {
		self._model = Bindable(wrappedValue: model)
	}
	
	var body: some View {
		NavigationStack(path: $navigation.path) {
			ItemList()
				.environment(navigation)
		}
	}
}
```

### Form with Validation
```swift
@Observable
class FormModel {
	var email: String
	
	init(email: String = "") {
		self.email = email
	}
	
	var isValid: Bool { email.contains("@") }
}

struct FormView: View {
	@SwiftUI.Bindable
	private var model: FormModel

	init(_ model: FormModel) {
		self._model = Bindable(wrappedValue: model)
	}

	var body: some View {
		Form {
			TextField("Email", text: $model.email)
			Button("Submit") { }
				.disabled(!model.isValid)
		}
	}
}
```

### Loading State
```swift
struct DataView: View {
	@SwiftUI.State
	private var data: [Item] = []

	@SwiftUI.State
	private var isLoading = false

	@SwiftUI.State
	private var error: Error?
	
	init() {}

	var body: some View {
		List(data) { item in
			Text(item.name)
		}
		.overlay {
			if isLoading {
				ProgressView()
			}
		}
		.task {
			isLoading = true
			defer { isLoading = false }

			do {
				data = try await fetchData()
			} catch {
				self.error = error
			}
		}
	}
}
```
