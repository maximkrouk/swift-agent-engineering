# UIFeedbackGenerator

Simple haptic feedback API for most common use cases. Available iOS 10+.

## Three Generator Types

### UIImpactFeedbackGenerator

Physical collision or impact sensation.

**Styles**: `.light`, `.medium` (most common), `.heavy`, `.rigid`, `.soft`

```swift
class MyViewController: UIViewController {
	private let impactGenerator: UIImpactFeedbackGenerator

	init(
		impactGenerator: UIImpactFeedbackGenerator = .init(style: .medium)
	) {
		self.impactGenerator = impactGenerator
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		self.impactGenerator = .init(style: .medium)
		super.init(coder: coder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.impactGenerator.prepare() // Reduces latency
	}

	@objc
	func buttonTapped() {
		self.impactGenerator.impactOccurred()
	}
}

// Intensity variation (iOS 13+): 0.0 to 1.0
impactGenerator.impactOccurred(intensity: 0.5)
```

### UISelectionFeedbackGenerator

Discrete selection changes. Feels like clicking a physical wheel.

```swift
private let selectionGenerator: UISelectionFeedbackGenerator = .init()

func pickerView(
	_ picker: UIPickerView,
	didSelectRow row: Int,
	inComponent component: Int
) {
	selectionGenerator.selectionChanged()
}
```

**Use cases**: Picker wheels, segmented controls, page indicators

### UINotificationFeedbackGenerator

System-level success/warning/error feedback.

```swift
let notificationGenerator: UINotificationFeedbackGenerator = .init()

func submitForm() {
	notificationGenerator.notificationOccurred(
		isValid ? .success : .error
	)
}
```

**Types**: `.success`, `.warning`, `.error`

## Performance: prepare()

Call `prepare()` before the haptic to reduce latency (~1 second window).

```swift
// Good: Prepare on touch down, fire on touch up
@IBAction
func buttonTouchDown(_ sender: UIButton) {
	self.impactGenerator.prepare()
}

@IBAction
func buttonTouchUpInside(_ sender: UIButton) {
	self.impactGenerator.impactOccurred() // Immediate
}
```

## Common Patterns

### HapticButton

```swift
class HapticButton: UIButton {
	private let impactGenerator: UIImpactFeedbackGenerator

	override init(frame: CGRect) {
		self.impactGenerator = .init(style: .medium)
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
		self.impactGenerator = .init(style: .medium)
		super.init(coder: coder)
	}

	override func touchesBegan(
		_ touches: Set<UITouch>,
		with event: UIEvent?
	) {
		super.touchesBegan(touches, with: event)
		self.impactGenerator.prepare()
	}

	override func touchesEnded(
		_ touches: Set<UITouch>,
		with event: UIEvent?
	) {
		super.touchesEnded(touches, with: event)
		self.impactGenerator.impactOccurred()
	}
}
```

### Slider Scrubbing

```swift
class HapticSlider: UISlider {
	private let selectionGenerator: UISelectionFeedbackGenerator
	private var lastValue: Float

	override init(frame: CGRect) {
		self.selectionGenerator = UISelectionFeedbackGenerator()
		self.lastValue = 0
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
		self.selectionGenerator = UISelectionFeedbackGenerator()
		self.lastValue = 0
		super.init(coder: coder)
	}

	@objc
	func valueChanged() {
		if abs(self.value - self.lastValue) >= 0.1 {
			self.selectionGenerator.selectionChanged()
			self.lastValue = self.value
		}
	}
}
```

### Pull-to-Refresh

```swift
func scrollViewDidScroll(_ scrollView: UIScrollView) {
	if scrollView.contentOffset.y <= -100 && !isRefreshing {
		impactGenerator.impactOccurred()
		isRefreshing = true
		beginRefresh()
	}
}
```

### Success/Error Feedback

```swift
func handleServerResponse(_ result: Result<Data, Error>) {
	let generator: UINotificationFeedbackGenerator = .init()
	switch result {
	case .success: 
		generator.notificationOccurred(.success)
	case .failure:
		generator.notificationOccurred(.error)
	}
}
```
