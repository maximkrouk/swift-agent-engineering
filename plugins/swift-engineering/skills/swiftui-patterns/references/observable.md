# @Observable — NOT ObservableObject

**iOS 17+ Pattern**

## ✅ Modern Pattern
```swift
import Observation

@Observable
class UserProfileModel {
	var name: String
	var email: String
	var isLoading: Bool
  
	init(
		name: String = "",
		email: String = "",
		isLoading: Bool = false
  ) {
		self.name = name
		self.email = email
		self.isLoading = isLoading
  }

	func save() async {
		isLoading = true
		defer { isLoading = false }
		// Save logic
	}
}

// In SwiftUI view
struct ProfileView: View {
	let model: UserProfileModel
	
	init(_ model: UserProfileModel) {
		self.model = model
	}

	var body: some View {
		TextField("Name", text: $model.name)
	}
}
```

## ❌ Deprecated Pattern
```swift
// NEVER use ObservableObject for new code
class UserProfileModel: ObservableObject {
	@Published
	var name: String = ""
	
	@Published
	var email: String = ""
}
```

## Why @Observable?

**Benefits:**
- **Less boilerplate** — no `@Published` needed
- **Better performance** — fine-grained observation (only tracks accessed properties)
- **Type-safe environment** — `@Environment(Type.self)` instead of `@EnvironmentObject`
- **Simpler bindings** — `@Bindable` instead of `@ObservedObject`

**Requirement:** iOS 17.0+ / macOS 14.0+
