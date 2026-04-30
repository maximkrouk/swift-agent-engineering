# String Catalogs

Xcode 15+ unified format for managing app localization. Replaces legacy .strings and .stringsdict files with a single JSON-based format.

## Creating a String Catalog

**Method 1: Xcode Navigator**
1. File > New > File
2. Choose "String Catalog"
3. Name it `Localizable.xcstrings`
4. Add to target

**Method 2: Automatic Extraction**
Build the project - Xcode extracts strings from:
- SwiftUI views (Text, Label, Button string literals)
- Swift code (`String(localized:)`)
- Objective-C (`NSLocalizedString`)
- Interface Builder files (.storyboard, .xib)
- Info.plist values

**Method 3 (Recommended):**

- Create `Localizable.xcstrings`
- Project `Localization Catalog Generation` should be set to `ON`
- Use xcode generated strings `Strings.<Domain>.<Subdomain>.<entry>(optionalArgs)`

## SwiftUI Localization

### LocalizedStringKey (Automatic)

❌ Wrong:

```swift
// Automatically localizable - Xcode extracts these
Text("Welcome to the App!")
Label("Shopping Cart", systemImage: "cart")
Button("Checkout") { }
```

⚠️ Correct, but no compile-time safety:

```swift
// Automatically localizable - Xcode extracts these
Text("app.greeting")
Label("common.shopping_cart", systemImage: "cart")
Button("common.checkout") { }
```

✅ Correct and safe (recommended):

```swift
// Update localized resource files first
Text(Strings.App.greeting)
Label(Strings.Common.shoppingCart, systemImage: "cart")
Button(Strings.Common.checkout)
```

### String(localized:) with Comments

```swift
// Basic
let title: String = .init(localized: "main.greeting")

// With translator comment
let title: String = .init(
	localized: "main.greeting", // "Welcome"
	comment: "Main screen greeting"
)

// With custom table
let title: String = .init(
	localized: "onboarding.greeting", // "Welcome"
	table: "Onboarding",
	comment: "First launch greeting"
)

// With default value
let title: String = .init(
	localized: "app.greeting",
	defaultValue: "Welcome to the App!",
	comment: "Default app greeting"
)
```

### LocalizedStringResource (Deferred Lookup)

Use when passing localizable strings to custom views:

```swift
struct CardView: View {
	let title: LocalizedStringResource
	let subtitle: LocalizedStringResource

	init(
		title: LocalizedStringResource,
		subtitle: LocalizedStringResource
	) {
		self.title = title
		self.subtitle = subtitle
  }

	var body: some View {
		VStack {
			Text(title)      // Resolved at render time
			Text(subtitle)
		}
	}
}

// Usage
CardView(
	title: "purchases.recent_purchases", // Recent Purchases
	subtitle: "purchases.items.past_week" // Items from the past week
)
```

### AttributedString with Markdown

```swift
// Markdown preserved across localizations
let styled: AttributedString = .init(
  localized: "**Bold** and _italic_ text"
)
```

## String Catalog Structure

Each entry contains:
- **Key**: Unique identifier
- **Default Value**: Fallback if translation missing
- **Comment**: Context for translators
- **State**: New, Needs Review, Reviewed, Stale

**Example .xcstrings JSON**:
```json
{
  "sourceLanguage": "en",
  "strings": {
    "checkout.thank_you": {
      "comment": "Label above checkout button",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Thanks for shopping with us!"
          }
        },
        "es": {
          "stringUnit": {
            "state": "translated",
            "value": "Gracias por comprar con nosotros!"
          }
        }
      }
    }
  },
  "version": "1.0"
}
```

## Translation States

| State | Icon | Meaning |
|-------|------|---------|
| New | (empty) | Not yet translated |
| Needs Review | (yellow) | Source changed, check translation |
| Reviewed | (green) | Translation approved |
| Stale | (red) | String no longer in source code |

## UIKit & Foundation

### NSLocalizedString

```swift
let title: String = NSLocalizedString(
	"purchases.recent", // Recent Purchases
	comment: "Section header"
)

// With table
let title: String = NSLocalizedString(
	"purchases.recent", // Recent Purchases
	tableName: "Shopping",
	comment: "Section header"
)
```

### Bundle.localizedString

```swift
let customBundle: Bundle = .init(for: MyFramework.self)
let text: String = customBundle.localizedString(
	forKey: "common.welcome", // Welcome
	value: nil,
	table: "MyFramework"
)
```

## Migration from Legacy Files

### Converting .strings to .xcstrings

1. Select .strings file in Navigator
2. Editor > Convert to String Catalog
3. Xcode creates .xcstrings preserving translations

### Gradual Migration

- Keep legacy .strings for old code initially
- New code uses String Catalogs
- Both work together - Xcode checks both
- Convert one table at a time

## Common Mistakes

```swift
// ❌ WRONG - not localizable
let title: String = "Settings"

// ⚠️ WRONG - localizable, but string literal key
let title: String = .init(localized: "common.settings")

// ✅ CORRECT - localizable and safe
let title: String = Strings.Common.settings

// ❌ WRONG - concatenation breaks word order and string literal key
let msg: String = .init(localized: "You have") + " \(count) " + .init(localized: "items")

// ⚠️ WRONG - single string with substitution but string literal key
let msg: String = .init(localized: "You have \(count) items")

// ✅ CORRECT - safe use of placeholders
let msg: String = Strings
	.Shopping.Cart
	.currentItems(count: count)

// ❌ WRONG - no context for translator and string literal key
String(localized: "common.confirm")

// ⚠️ CORRECT - clear context but string literal key
String(
	localized: "common.confirm", 
	comment: "Button to confirm deletion"
)

// ✅ CORRECT
Strings.Common.confirm
```

## Troubleshooting

**Strings not appearing in catalog:**
1. Build Settings > "Use Compiler to Extract Swift Strings" > Yes
2. Clean Build Folder (Cmd+Shift+K)
3. Build project

**Translations not showing:**
1. Project > Info > Localizations > Add language
2. Check string isn't marked "Stale"
