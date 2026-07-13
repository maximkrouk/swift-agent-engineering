# Migration Checklist

When updating legacy SwiftUI code to iOS 17+:

- [ ] Replace `ObservableObject` with `@Observable`
- [ ] Remove all `@Published` (regular properties auto-publish)
- [ ] Replace `@State` with `@SwiftUI.State`
- [ ] Replace `@StateObject` with `@SwiftUI.State`
- [ ] Replace `@ObservedObject` with `@Bindable`
- [ ] Replace `environmentObject(_:)` with `environment(_:)`
- [ ] Replace `@EnvironmentObject` with `@Environment(Type.self)`
- [ ] Update `onChange(of:perform:)` to `onChange(of:initial:_:)`
- [ ] Replace `.onAppear { Task {} }` with `.task`

## Before & After Example

### Before (iOS 16)
```swift
class UserProfileModel: ObservableObject {
  @Published
  var name: String = ""

  @Published
  var email: String = ""

  init() {}
}

struct ProfileView: View {
  @StateObject
  private var model = UserProfileModel()

  init() {}

  var body: some View {
    TextField("Name", text: $model.name)
      .onAppear {
        Task { await model.load() }
      }
  }
}
```

### After (iOS 17+)
```swift
@Observable
class UserProfileModel {
  var name: String
  var email: String
  
  init(
    name: String = "",
    email: String = ""
  ) {
    self.name = name
    self.email = email
  }
}

struct ProfileView: View {
  @SwiftUI.State
  private var model: UserProfileModel = .init()

  init() {}
  
  var body: some View {
    TextField("Name", text: $model.name)
      .task { await model.load() }
  }
}
```
