# Reducer Structure, Actions, and State

Detailed patterns for structuring TCA reducers, organizing actions, and defining state.

> [!Note]
> 
> _If you find any comments  in templates, they are added for the context and should not be present in the output_
## Reducer Structure

### General rules

- APIs are public by default, except of:
  - Reducer properties marked with `@Dependency` are `private`
  - Derived reducers are `private` and such properties have `Reducer` suffix
- Initializers are always explicit, each initializer argument must be placed on a new line
- Attributes are explicit and never share the same line with attachment target
- Root-level feature reducers must always have `Feature` suffix (basically must match module name)
- Derived reducers:
  - `uiReducer` is a common one for mapping `UI` actions to logical ones
  - `Event` actions should be handled by domain-specific reducers unlike `UI` actions
  - `Delegate` actions are not handled
- General structure:
  - Basic stored properties if needed (inline dependencies)
    - Tho usually it's only applicable to some generic reducers that are meant to share the logic, generally dependencies should be injected using `@Dependency`
  - `public` init
    - Usually empty
  - Nested domain-specific types if needed
    - For example if feature has some activities that should be reflected in state it makes sense do declare `public struct Activities: OptionSet {...}` in the feature and `public var runningActivities: Activities`  in it's state.
  - State type declaration
  - Actions type declaration
  - `@Dependency`ies declaration
  - `public var body: some ReducerOf<Self> {...}`
  - private derived reducers

### Basic Reducer Template

```swift
import _ComposableArchtiecture

@Reducer
public struct <#Domain#>Feature {
	public init() {}

	@ObservableState
	public struct State: Equatable, Sendable {
		public init() {}
	}

	@CasePathable
	public enum Action: SharedBindableAction, Equatable, Sendable {
		case ui(UI)
		case event(Event)
		case delegate(Delegate)
		case shared(SharedBindingAction<State>)
		case observation(ObservationAction<Observation>)
		// <internal business logic actions here>
		
		@CasePathable
		public enum UI: Equatable, Sendable {}
		
		@CasePathable
		public enum Event: Equatable, Sendable {}
		
		@CasePathable
		public enum Delegate: Equatable, Sendable {}

		@CasePathable
		public enum Observation: Equatable, Sendable {}
	}
	
	public var body: some ReducerOf<Self> {
		CombineReducers {
			uiReducer
		}
	}

	private var uiReducer: some ReducerOf<Self> {
		EmptyReducer() 
	}
}
```

### Nested Reducer Template

Sometimes it's useful to extract some logic into a separate component without creating a new feature module. To keep module entry point clean, it's nice to declare such components as nested reducers, their basic template is pretty much the same as the one described above, the main difference is that we can omit "Feature" suffix.

```swift
import _ComposableArchitecture

extension <#Domain>Feature {
	@Reducer
	public struct <#Subdomain#> {
		// Basically the same structure as `Basic Reducer Template`
		// The only differences are nesting and type name
	}
}
```

### State structure

State should:

- Always be marked with `@ObservableState`
- Conform to `Equatable` and `Sendable` when possible
- Follow the following structure
  - stored properties
    - do not use default values when not required
    - default values are required for properties marked as `@Shared` 

  - initializers
    - usually just 1 explicit public initializer
    - explicit public init must initialize all properties (except of ones marked with `@Shared`)
    - each argument must be declared on a new line
    - each argument should have a default value

  - computed properties/functions if needed

- Semantically layout stored properties with following priority list
  - atomic local state (id, local values)
  - complex local state (collections, custom types)
  - child state (stored state of subfeatures)
  - attributed stored properties (like ones marked with `@Presents`)
  - shared state (properties marked with `@Shared`)



```swift
@ObservableState
public struct State: Equatable, Sendable {
	public var value1: Int
	public var value2: Int
	public var child1: Child1Feature.State
	public var child2: Child1Feature.State
		
	@Presents
	public var nestedChild: NestedChild.State?

	@Shared(.inMemory(\.someSharedKeyDomain.someEntry))
	public var sharedValue: Int = 0
		
	public init(
		value1: Int = 0
		value2: Int = 0,
		child1: Child1Feature.State = .init(),
		child2: Child2Feature.State = .init(),
		nestedChild: NestedChild.State? = nil
	) {
		self.value1 = value1
		self.value2 = value2
		self.child1 = child1
		self.child2 = child2
		self.nestedChild = nestedChild
	}
}
```

### Action structure

Actions should:

- Always be marked with `@CasePathable`
- Conform to `Equatable` and `Sendable` when possible
- Feature actions should contain core subactions:
  - `UI` - actions that are sent from UI
  - `Event` - actions that are sent from Effects
  - `Delegate` - actions that are not handled in the reducer and meant for external handling
- Follow the following structure:
  - core subactions
  - specific generic actions
    - BindingActions
    - PresentationActions
  - child actions
  - internal actions
    - these ones are triggering the logic
  - core subactions type declarations
  - other nested type declarations
    - i.e. `public enum Observation: Equatable, Sendable { ... }`

```swift
@CasePathable
public enum Action: Equatable, Sendable {
	case ui(UI)
	case event(Event)
	case delegate(Delegate)
	// case shared(SharedBindingAction<State>) // requres SharedBindableAction conformance
	// case observation(ObservationAction<Observation>) // requres Observation enum declaration
	// case binding(BindingAction<State>) // requres BindableAction conformace
	//
	// case someChild(PresentationAction<SomeChildFeature.Action>)
	//
	// case performWork


	@CasePathable
	public enum UI: Equatable, Sendable {}

	@CasePathable
	public enum Event: Equatable, Sendable {}

	@CasePathable
	public enum Delegate: Equatable, Sendable {}

	@CasePathable
	public enum Observation: Equatable, Sendable {}
}
```

### Handling actions

#### Pullbacks

For actions prefer composition of `Pullback` reducers over `switch` statements

```swift 
// case someSimpleAction
Pullback(\.someSimpleAction) { state in
	state.simpleActionsCount += 1
	return .none
}
```

```swift 
// case updateValue(Int)
Pullback(\.updateValue) { state, value in 
	state.value = value
	return .none
}
```

```swift 
// case paths to nested actions are also supported
Pullback(\.ui.submitButtonTap) { state in 
	return .send(.submit)
}
```

```swift 
// identified array actions are also supported
Pullback(\.elements, action: \.delegate.delete) { state, id in
	state.elements.remove(id: id)
	return .none
}
```

Main pullback variants:

- pullback to child action
  - if target has no associated values, pullback handler only accepts current state
  - if target has associated value (i.e. child action), pullback handler accepts current state and associated value
- pullback to identified array element action
  - this overload accepts 2 case paths
    - first one is a path to collection
    - second one is a path from element to child action
  - if final target has no associated values, pullback handler only accepts current state and element id
  - if target has associated value (i.e. child action), pullback handler accepts current state, element id and associated value

### 

### @Reducer Enum Conformances

**CRITICAL**: `@Reducer` enum definitions must use extensions for protocol conformances like `Equatable` or `Sendable`. Never add conformances directly to the `@Reducer` declaration.

```swift
// ❌ INCORRECT - Do not add conformances directly
@Reducer
struct SomeFeature: Sendable {
	// ...
}

// ✅ CORRECT - Use extension for conformances
@Reducer
public struct SomeFeature {
	// ...
}

extension SomeFeature: Sendable {}
```

**Pattern**: Always define the extension at file scope, directly after the parent reducer's closing brace:

```swift
extension ParentFeature {
	@Reducer
	public enum Destination {
		case settings(SettingsFeature)
		case detail(DetailFeature)
	}
}

extension ParentFeature.Destination.State: Equatable {}
extension ParentFeature.Destination.Action: Equatable {}
```

**Why this is required**: The `@Reducer` macro generates code that conflicts with conformances added directly to the enum declaration. Extensions allow the macro-generated code to work correctly while still providing the necessary protocol conformances.

## Handling errors

Use `Result` types with `Equtated` errors for async operation responses to handle both success and failure cases when error type is unknown or known as not `Equatable`

```swift
@CasePathable
public enum Event: Equatable, Sendable {
	case didFinishProcessing(Result<String, Equated<any Error>)
}
```

Tho sometimes it's useful to have semantic separation

```swift
@CasePathable
public enum Event: Equatable, Sendable {
	case didLoadItem(Item)
	case didFailToLoadItem(Equated<any Error>)
}
```

Choose what's more ergonomic in given context

### Result with catch:

You can also use the `catch:` parameter in effects:

```swift
Pullback(\.loadItem) { state, id in 
	return .run { send in
		let item = try await apiClient.fetchItem(id)
		await send(.event(.didLoadItem(item)))
	} catch: { error, send in
		await send(.event(.didFailToLoadItem(.init(error))))
	}
}
```

### Processing  errors

Depending on the error there are a few options for error handling:

#### Omitting errors

It might be useful to omit error handling

- for the first path for implementing the feature
- for insignificant/frequent errors, for example when observing some stream of events

To omit the error use `withErrorReporting`

```swift
Pullback(\.loadItem) { state, id in 
	return .run { send in
		await withErrorReporting {
			let item = try await apiClient.fetchItem(id)
			await send(.event(.didLoadItem(item)))
		}
	}
}
```

#### Recovering from errors

It's usually a good idea to implement attemt to recover from an error, usually it's better to do it on the dependency level, however it might be useful in reducers as well (for example if initial recovery didn't work)

Generic approach is to display an alert with retry option