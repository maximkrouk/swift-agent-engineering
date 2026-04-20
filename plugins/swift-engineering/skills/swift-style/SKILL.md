---
name: swift-style
description: Swift code style conventions for clean, readable code. Use when writing Swift code to ensure consistent formatting, naming, organization, and idiomatic patterns.
---
# Swift Style Guide

Code style conventions for clean, readable Swift code.

## Core Principles

**Clarity > Brevity > Consistency**

Code should compile without warnings.

## Indentation Style

- Prefer indentation from `.editorconfig` file
- If `.editorconfig` file is missing infer indentation for the project and create `.editorconfig` file
- For new projects create the following `.editorconfig`
  ```ini
  root = true
  
  [*]
  indent_style = tab
  tab_width = 2
  trim_trailing_whitespace = true
  insert_final_newline = true
  
  [*.yml]
  indent_style = space
  indent_size = 2
  ```
  
  > [!Important]
  > 
  > `yaml` files should always be indented with spaces, `Makefile`s should also be indented with tabs

- If the project contains forks or subprojects, prefer local `.editorconfig`s over the root one for sources of such projects

## Naming

- `PascalCase` — Types, protocols
- `camelCase` — Everything else
- Sometimes it makes sense to prefix private/internal stuff with an underscore (`_`) or double underscore (`__`), especially when the name matches some less restrictive API or when the private API is publically exposed using `@_spi`
- Clarity at call site
- No abbreviations except universal (URL, ID, idx, ios)
	- Usually each letter of the acronym must be in the same case (`url`/`URL`, `id`/`ID`)
	- Exceptions are some non-acronym abbreviations (idx/Idx) and branded names, when brand name always starts with a lowercase, prefix it with an underscore when it's not the first token of the identifier (`ios`/`_iOS`)
	- Very simple functions or some generic ones can use simple identifiers for arguments
	
	  ```swift
	  func sum(_ a: Int, _ b: Int) -> Int { a + b }
	  ```
	
	  ```swift
	  func pipe<A, B, C>(
	  	_ f0: @escaping (A) -> B,
	    _ f1: @escaping (B) -> C
	  ) -> (A) -> C {
	    return { a in f1(f0(a)) }
	  }
	  ```
	
- Default `@_spi` for exposing private APIs is `Internals` (`@_spi(Internals)`)

```swift
let maximumWidgetCount = 100
func fetchUser(byID id: String) -> User
```

## Conditional statements

> [!Note]
>
> One of the drivers for shape selection is ergonomics and visual separation of domains, here are a few guard statement exampes:
>
> ```swift
> // MARK: CORRENT ✅ no separation, but the expression is
> // super simple and doesn't need it
> guard let self else { return }
> 
> // MARK: CORRENT ✅ soft [condition vs else] separation,
> // this might be a bit redundant, but still reads well
> guard let self
> else { return }
> 
> // MARK: CORRENT ✅ soft [condition vs else] separation
> //for simple conditions and else branches
> guard let first = candidates.first(where: condition)
> else { throw LocalError.noMatchingCandidatesFound }
> 
> // MARK: CORRENT ✅ else block separation with indentation
> // when else branch is complex
> guard let self else {
> 	logger.logError("self is missing")
> 	service.cleanup()
> 	return
> }
> 
> // MARK: CORRENT ✅ else block separation with indentation
> // when else branch is much longer than the condition,
> // this balances out the weight of the expression
> guard let self else {
> 	throw LocalError.somthingUnexpectedHappened
> }
> 
> // MARK: CORRENT ✅ complex conditions are visually separated with indentation,
> // simple else block is on a separate line
> 
> // extracted complex expression out of the guard statment
> // to simplify it
> var firstInt: Int? { strings.first { Int($0) }.flatMap { Int($0) } }
> guard
> 	let self,
> 	let firstInt,
> 	firstInt.isMultiple(of: 2)
> else { return nil }
> 
> // MARK: CORRENT ✅ conditions and else branch both
> // are strongly visually separated with indentation
> 
> guard
> 	let self,
> 	let firstInt,
> 	firstInt.isMultiple(of: 2)
> else { 
> 	logger.logError("something went wrong")
> 	service.cleanup()
> 	throw LocalError.unexpectedFailure
> }
> 
> // MARK: WRONG ❌ Expression is too long to be defined
> // as a one-liner, `else { return }` must be placed on a new line
> guard let pattern = loadAHAPPattern(named: "ShieldTransient") else { return }
> 
> // MARK: WRONG ❌ not enough visual separation, conditions are complex enough,
> // but the first one competes with `guard` keyword for reader's attention.
> // Also such separation doesn't work well with tabs indentation.
> // `let self` must be placed on a new line, other conditions indentations
> // should be adjusted
> guard let self,
>    let firstInt,
>    firstInt.isMultiple(of: 2)
> else { return nil }
> 
> // MARK: WRONG ❌ both condition and else branch
> // are equally super simple, but else branch separation
> // is too strong
> guard let self else {
> 	return nil
> }
> 
> 
> // MARK: WRONG ❌ both condition and else branch
> // are equally super simple, but else branch is much
> // longer than the condition and this could be more balanced
> guard let self
> else { throw LocalError.somthingUnexpectedHappened }
> ```
>
> Same approach can be applied for other conditional statments and function calls, indentation is a powerful tool for improving code readability and should be used intentionally. Same patterns can be applied to function declarations and calls, or lists of generic type constraints, for example
>
> ```swift
> // WRONG ❌ Expression takes too much space and could be optimized
> class MyComplexCustomView<CompexCustomDelegate, ComplexCustomDataSource, Content> { ... }
> 
> // CORRECT: ✅ Clear visual separation of type identifier and generic constraints
> class MyComplexCustomView<
> 	CompexCustomDelegate,
> 	ComplexCustomDataSource,
> 	Content
> > { ... }
> ```
>

### Guard

Short `guard` statements can be expressed in one line if `else` block doesn't contain complex logic that requires multiple lines

```swift
guard let self else { return }

guard let self else { return fallback() }

guard let self else {
  // custom logic or multiple external calls
  return nil
}
```
Medium `guard` statements can be expressed in 2 lines, especially when there is a single function call in `else` branch, single function calls can be placed directly after return if types match, same goes for throws in guard statements:

```swift
guard input.someConditionThatMustBeSatisfied()
else { return cleanup() }
```

```swift
guard input.someConditionThatMustBeSatisfied()
else { throw LocalError.inputCorrupted }
```

```swift
guard input.someConditionThatMustBeSatisfied() else {
  // custom logic or multiple external calls
 	return
}
```

Multiline conditions in `guard` statements must place each condition on a separate line, except of really short ones, simple return statments must be placed in one line with `else` keyword, complex `else` branches may need to be declared as multiline

```swift
guard isNumber, isFinite
else { return nil }
```

```swift
guard
	input.firstCondition,
	input.secondCondition
else { return }
```

```swift
guard
	input.firstCondition,
	input.secondCondition
else { 
	// some more work
	return
}
```

### If

Simple `if` statments can be expressed as one-liners

```swift
if exitEarly { return }
```

Multiline conditions in `if` statements is discouraged, if the statment is short enough keep one-liner, extract conditions to a local variable otherwise

```swift
if isNumber, isFinite {
	// work
} else {
	// other work
}
```

```swift
let isOddNumberValidAndCached = cache.contains(number)
&& validate(number)
&& !number.isMultiple(of: 2)

if isOddNumberValidAndCached {
	// work
}
```

### Switch

`switch` statments always must use `case let ._(value)`  instead of `case ._(let value)`

Simple `switch` statements can handle cases as one-liners

```swift
switch self {
case .normal: .normal
case .custom: .custom
}
```

Medium `switch` statements should handle cases on a new line

```swift
switch action {
case .someWork:
	// perform some work
case .someOtherWork:
  // perform some other work
}
```

Cases in complex `switch` statments must have an extra newline

```swift
switch action {
case .someWork1:
	// perform some work1
	
case .someWork2:
  // perform some work2
  
case .someWork3:
  // perform some work2
}
```

Same can be applied to `if` statments with complex logic

```swift
if condition {
  // complex logic

} else {
  // else block is prefixed with
  // a trailing newline in `if` block
}
```

### Ternary operators

For very simple mappings it's ok to use nested ternary operators, but generally nesing of ternary operators is discouraged

```swift
return isPrimeRequred
? (isRandom ? primeCandidates.random() : primeCandidates.first)
: (isRandom ? allCandidates.random() : allCandidates.first)
```

Prefer ternary operators over `if` statements for assignments

```swift
let output: String = if forceUppercase { string.uppercased() } else { string } // ❌
let output = forceUppercase ? string.uppercased() : string // ✅
```

Prefer `switch` statments over ternary operators for complex assignments

```swift
// ❌
let value = input == .zero
? 0 : input == .one
? 1 : .max

// ✅
let value: Int = switch input {
case .zero: 0
case .one: 1
case .max: .max
}
```

## Golden Path

Left-hand margin is the happy path. Avoid redundant nesting of `if` statements.

```swift
func process(value: Int?) throws -> Result {
	guard let value else { throw ProcessError.nilValue }
  guard value > 0 else { throw ProcessError.negativeValue }
  return compute(value)
}
```

## Self

Generally perfer explicit `self`, always use explicit `self` when method contains a `super` call

```swift
// Without swift-declarative-configuration
override func _init() {
	super._init()
	self.backgroundColor = .systemBackground
}
```

```swift
// With swift-declarative-configuration
override func _init() {
	super._init()
	self.configure { $0 
		.backgroundColor(.systemBackground)
	}
}
```

## Declarations

### General rules

- Specify types for properties explicitly

  ```swift
  let value: Int = 0
  var object: AnyObject?
  ```

  > [!Note]
  >
  > Specifically when using `swift-declarative-configuration` use the following pattern to avoid hitting a runtime swift bug with `callAsFunction` calls:
  >
  > ```swift
  > // Type is implicit on the left side
  > // Type is explicit on the right side
  > let someView = SomeView() { $0 
  > 	.backgroundColor(.red)
  > 	.alpha(0.8)
  > }
  > ```

- Use syntactic sugar for first-class swift types

  - `Value?` instead of `Optional<Value`

    ```swift
    let value: Int? = nil
    ```

  - `[Value]` instead of `Array<Value>`

    ```swift
    let array: [Int] = []
    ```

  - `[Key: Value]` instead of `Dictionary<Key, Value>`

    ```swift
    let dict: [String: Int] = [:]
    ```

  - Exceptions are:

    - Custom types like `IdentifiedArray`, `OrderedSet` etc.

    - Extensions should prefer explicit type + where clause

      ```swift
      extension Array where Element: StringProtocol { ... }
      ```

- Attributes must always be placed on separate lines

  ```swift
  @Reducer
  struct CustomFeature { ... }
  
  @SwiftUI.State
  private var value: Int = 0
  
  @inlinable
  func test() {}
  
  @objc
  func test() {}
  
  @available(
  	*, deprecated,
    message: """
    Don't use this method,
    it's deprecated
    """
  )
  @objc
  func test() {}
  ```

  - In general-purpose packages mark public functions as `@inlinable` and internal properties/functions as `@usableFromInline` attributes
  - SwiftUI `State` attribute must always be prefixed with module name `@SwiftUI.State` instead of `@State`

- For readonly computed properties omit `get` keyword

  - Simple readonly computed properties can be declared as one-liners
  
    ```swift
    var diameter: Double { radius * 2 }
    ```
  

### Structure

#### Properties/Functions

- attributes
- access modifier
- `override` keyword
- `static`/`final` keyword
- identifier

```swift
open override static var value: Int
```

#### Functions

Simple function shape with 1 arg is

```swift
func test(_ value: Int) {}
```

If function has multiple arguments, each argument should be written on a separate line (except of trivial cases):

```swift
func sum(_ a: Int, _ b: Int) -> Int { a + b } // ok even as a one-liner
```

```swift
// this one must declare each arg on a new line
func sendRequest(
	_ request: URLRequest,
  using session: URLSession
) async throws -> (Data, Response) {
  // body
}
```

Functions, generic over 1 argument should have the following shape with each arg on a new line (except of super simple ones):

```swift
func identifier<Arg>(
	_ arg: Arg
) -> Output {
  // body
}
```

Simple generic constraints can be put into generic args list

```swift
func identifier<Arg: Equatable>(
	_ arg: Arg
) -> Output {
  // body
}
```

Multiple generic args must be placed on separate lines as well as args

```swift
func identifier<
	Arg1,
	Arg2
>(
	_ arg1: Arg1,
  _ arg2: Arg2
) -> Output {
  // body
}
```

Complex generic constraints must be placed in where clauses, if where clause is needed, move constraints from generic argument list to the clause, multiple expressions in the where clause must be placed on new lines, here is an example of complex function declaration:

```swift
@inlinable
public static func someFunction<
	Arg1,
	Arg2
>(
	_ arg1: Arg1,
  _ arg2: Arg2
) async throws -> Output where
	Arg1: Equatable & Sendable,
	Arg2: Equatable & Sendable
{
  // body
}
```

#### Type declarations

Type declaration contents must use the following structure:

- operator overrides (for example `==` for `Equatable` conformance)

- stored properties

  - plain or attributed with `@usableFromInline`

    sorted either semantically or by access modifiers `private` -> `internal` -> `package` -> `public` -> `open`

  - attributed with propertyWrappers/macros

    sorted either semantically or by access modifiers `private` -> `internal` -> `package` -> `public` -> `open`

- initializers

  - convenience
  - designated
  - required
  - initialization helpers (like `_init` function override)
  - method overrides (for classes)

- computed properties

- methods

  - `hash(into:)` method if needed
  - other methods

- extensions

  - extracted computed properties, helper methods, nested types

- local extensions of imported types

##### Structs

- Do not use default values for properties
- Always generate initializer, use default arguments if needed
- Usually structs should have a designated init that accepts all properties, convenience initializers should call that init

##### Enums

- Start with enum cases
- Enums can contain nested types in base type declaration after cases (without extracting them into an extension)

##### Classes

- If class is not supposed to be subclassed, mark class as `final`

## Function calls

Most functions with one argument, or short functions with multiple arguments (especially without labels) can be used as a one-liner:

```swift
print(sum(2, 2)) // 4

let _sum = curry(sum)
let addOneTo = _sum(1)
print(addOneTo(2)) // 3

super.viewDidAppear(animated: animated)
```

But functions calls with multiple arguments (especially with labels) should place args on separate lines:

```swift
let cardView = CardView(
	model: cardModel,
	style: cardStyle
)
```

When using `swift-declarative-configuration` package the shape of the trailing closure should be

```swift
let redRoundedView = CocoaView() { $0 
	.backgroundColor(.red)
	.layer.scope { $0 
		.cornerCurve(.continuous)
		.cornerRadius(12)
	}
}
```

> [!Important]
>
> Swift function calls should NEVER use objc call notation
>
> ```swift
> // WRONG ❌
> someFunction(arg1: 0
>              arg2: 1)
> 
> // CORRECT ✅
> someFunction(
> 	arg1: 0
> 	arg2: 1
> )
> ```
>
> It's important because:
>
> - indentation is a way to declare visual context and objc kinda loses it
>
>   ```
>   // bad visual separation of contexts
>   <identifier>(<first-arg-line>
>                <next-arg-lines>)
>   ```
>
>   vs
>
>   ```
>   // good visual separation of contexts
>   <identifier>(
>   	<arg-lines>
>   )
>   ```
>
>   - `objc` notation doesn't work well with tabs indentation

## Memory Management

```swift
resource.request().onComplete { [weak self] response in
	guard let self else { return }
	self.updateModel(response)
}
```

If `swift-capture` is available:

```swift
resource.request().onComplete(perform: capture { _self, response in 
	_self.updateModel(response)
})
```

## Comments

- Explain **why**, not what
- Use `//` or `///`, avoid `/* */`
- For doc comments always perfer `- Parameters` list instead of single `- Parameter` statements, even if function has only one parameter
- Keep up-to-date or delete
- For complex files use `// MARK:` comments
  - Semantic code sections can be highlighted with `// MARK: -` comments
  - Subsections of such sections can use `// MARK:` comments

## Omitting errors

If erros shouldn't be handled properly (initial pass implementation, some observations) instead of printing an error in `do/catch` block it's highly recommended to use `IssueReporting` by `pointfreeco`

```swift
// WRONG ❌: Error is completely ignored
try? produceError()

// WRONG ❌: API is not very ergonomic
// and `print` is not the best logging strategy
do {
  try produceError()
} {
  print(error)
}

// CORRECT ✅: Delegates handling to reporters API
// depending on context reporters can use osLog or raise
// a runtime warning underthehood
withErrorReporting {
  try produceError()
}
```



## Common Mistakes

1. **Abbreviations beyond URL, ID, UUID** — Abbreviations like `cfg`, `mgr`, hurt readability. Spell them out: `configuration`, `manager`. Exceptions are
   - `ctx` - context, it's allowed tho discouraged.
   - `idx` - index, it's allowed tho discouraged
   - Well-known acronyms are allowed and encouraged: `ID`, `UUID`, `URL`, `URI` etc.
2. **Nested guard/if statements** — Deep nesting makes code hard to follow. Use early returns and guards to keep the happy path left-aligned. Tho it's ok to have nested conditions if it improves readability in rare cases.
3. **Inconsistent self usage** — Either always omit `self` or always use it (preferred). Mixing makes code scanning harder and confuses capture semantics.
4. **Overly generic type names** — `Manager`, `Handler`, `Helper`, `Coordinator` are too vague. Names should explain responsibility: `PaymentProcessor`, `EventDispatcher`, `ImageCache`, `MainCoordinator`. However they can be used for:
   - Generic components (rarely), for example `Handler<each T>` which could provide APIs for handling generic input
   - Nested types - when domain is already specified by the namespace
5. **Implied access control** — Don't skip access control. Explicit `private`, `internal`, `package`, `public` helps future maintainers understand module boundaries. Always explicitly specify access control.
6. **Placing attributes on the same line with the declaration** — Always place attributes on separate lines.
