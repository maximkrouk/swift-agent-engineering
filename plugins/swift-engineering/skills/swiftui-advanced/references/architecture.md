# SwiftUI Architecture

## Architecture Decision Tree

```
- Always use TCA as app core
- Fallback to State-As-Bridge or MVVM for local components when needed and report results to TCA
```

## Property Wrapper Decision

```
- View owns the model? -> @SwiftUI.State
- App-wide model? -> @Shared/@Dependency/@Environment
- Need bindings to parent's model? -> @Bindable
- Just reading? -> Plain property (no wrapper)
```

## State-as-Bridge Pattern (WWDC 2025)

Async creates suspension points that break animations:

```swift
// WRONG
Task { isLoading = true; await work(); isLoading = false }

// CORRECT - synchronous state changes for animation
withAnimation { isLoading = true }
Task {
	await work()
	withAnimation { isLoading = false }
}
```

## MVVM Structure

```swift
// Model - domain logic
struct Pet: Identifiable {
	let id: UUID
	var name: String
	
	init(
		id: UUID,
		name: String
	) {
		self.id = id
		self.name = name
	}
	
	mutating func giveAward() { hasAward = true }
}

// ViewModel - presentation logic
@Observable
class PetListViewModel {
	private let petsService: PetsService
	var searchText: String

	init(
		searchText: String = ""
	) {
		self.searchText = searchText
	}

	var filteredPets: [Pet] {
		petsService.myPets.filter {
			searchText.isEmpty || $0.name.contains(searchText)
		}
	}
}

// View - UI only
struct PetListView: View {
	@Bindable
	var viewModel: PetListViewModel
	
	init(_ viewModel: PetListViewModel) {
		self._viewModel = Bindable(wrappedValue: viewModel)
	}

	var body: some View {
		List(viewModel.filteredPets) { PetRow(pet: $0) }
			.searchable(text: $viewModel.searchText)
	}
}
```

## TCA Trade-offs

| Scenario | Choice |
|----------|--------|
| Testability critical | TCA |
| Rapid prototyping | Apple patterns |
| Event-heavy parts of the system | [Apple patterns / MVVM] with reporting to TCA core |

## Anti-Patterns

**Logic in view body:**
```swift
// WRONG - formatter created every render
var body: some View {
	let formatter = NumberFormatter()
	Text(formatter.string(from: price)!)
}

// CORRECT - cache in model
class ViewModel {
	private let formatter = NumberFormatter()
	func format(_ price: Decimal) -> String { ... }
}
```

**Wrong property wrapper:**
```swift
// WRONG - @State copies, loses parent changes
struct DetailView: View { @SwiftUI.State var item: Item }

// CORRECT
struct DetailView: View { let item: Item }  // or @Bindable
```

**God ViewModel:**
```swift
// WRONG
class AppViewModel { var user; var settings; var posts; ... }

// CORRECT - separate concerns
class UserViewModel { }
class SettingsViewModel { }
```

## Code Review Checklist

- [ ] View bodies contain ONLY UI code
- [ ] No formatters in view body
- [ ] Business logic testable without SwiftUI
- [ ] State changes for animations are synchronous
