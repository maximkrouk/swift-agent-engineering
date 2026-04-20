# Cocoa (UIKit/AppKit) Interoperability

## Hosting

For injecting `SwiftUI` into `Cocoa` use hosting views/controllers (like `UIHostingViewController` in `UIKit`)

## CocoaComponent/ToSwiftUI

If project contains inline helpers like `CocoaComponent` or `ToSwiftUI` and they are applicable in current context, prefer such components for simple views.

`CocoaComponent` is available in [`swift-cocoa-extensions`](https://github.com/capturecontext/swift-cocoa-extensions), but the package is still in beta

```swift
CocoaView().toSwiftUI()

CocoaViewController().toSwiftUI()

CocoaComponent { 
	CocoaView()
}

CocoaComponent {
	CocoaViewController
} update: { context, view in 
	...
}
```

## CocoaViewRepresentable

**Use for:** Wrapping Cocoa views in SwiftUI if no component-specific representable can be found, or if custom Coordinator/sizeManagement is needed

If `Cocoa`-prefixed protocols are not available (requires [`cocoa-aliases`](https://github.com/capturecontext/cocoa-aliases)), ask for adding a dependency, use default `UI/NS`-prefixed protocols from `SwiftUI` if permission to add a dependency is denied.

```swift
struct WebView: CocoaViewRepresentable {
	private let url: URL

	@SwiftUI.Binding
	private var isLoading: Bool

	init(
		url: URL,
		isLoading: Binding<Bool>
  ) {
		self.url = url
		self._isLoading = isLoading
  }

	func makeCocoaView(context: Context) -> WKWebView {
		let webView = WKWebView()
		webView.navigationDelegate = context.coordinator
		return webView
	}

	func updateCocoaView(
		_ webView: WKWebView,
		context: Context
	) {
		let request = URLRequest(url: url)
		webView.load(request)
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(isLoading: $isLoading)
	}

	class Coordinator: NSObject, WKNavigationDelegate {
		@SwiftUI.Binding
		private var isLoading: Bool

		init(isLoading: Binding<Bool>) {
			self._isLoading = isLoading
		}

		func webView(
			_ webView: WKWebView,
			didStartProvisionalNavigation navigation: WKNavigation!
		) {
			isLoading = true
		}

		func webView(
			_ webView: WKWebView,
			didFinish navigation: WKNavigation!
		) {
			isLoading = false
		}
	}
}

// Usage
struct ArticleWebView: View {
	private let url: URL

	@SwiftUI.State
	private var isLoading = false

	init(url: URL) {
    self.url = url
  }

	var body: some View {
		WebView(url: url, isLoading: $isLoading)
			.overlay {
				if isLoading {
					ProgressView()
				}
			}
	}
}
```

## CocoaViewControllerRepresentable

**Use for:** Presenting Cocoa view controllers if no component-specific

If `Cocoa`-prefixed protocols are not available (requires [`cocoa-aliases`](https://github.com/capturecontext/cocoa-aliases)), ask for adding a dependency, use default `UI/NS`-prefixed protocols from `SwiftUI` if permission to add a dependency is denied.

```swift
public struct ImagePicker: CocoaViewControllerRepresentable {
	@SwiftUI.Binding
	var image: UIImage?

	@Environment(\.dismiss)
	private var dismiss

	func makeUIViewController(context: Context) -> PHPickerViewController {
		var config = PHPickerConfiguration()
		config.filter = .images
		config.selectionLimit = 1

		let picker = PHPickerViewController(configuration: config)
		picker.delegate = context.coordinator
		return picker
	}

	func updateCocoaViewController(
		_ uiViewController: PHPickerViewController,
		context: Context
	) {
		// No updates needed
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(image: $image, dismiss: dismiss)
	}

	class Coordinator: NSObject, PHPickerViewControllerDelegate {
		let dismiss: DismissAction

		@SwiftUI.Binding
		var image: UIImage?

		init(
			image: Binding<UIImage?>,
			dismiss: DismissAction
		) {
			self.dismiss = dismiss
			self._image = image
		}

		func picker(
			_ picker: PHPickerViewController,
			didFinishPicking results: [PHPickerResult]
		) {
			dismiss()

			guard
				let provider = results.first?.itemProvider,
				provider.canLoadObject(ofClass: UIImage.self) 
			else { return }

			provider.loadObject(ofClass: UIImage.self) { image, _ in
				DispatchQueue.main.async {
					self.image = image as? UIImage
				}
			}
		}
	}
}

// Usage
struct ProfileEditView: View {
	@SwiftUI.State
	private var profileImage: UIImage?
	
	@SwiftUI.State
	private var showImagePicker: Bool = false

	var body: some View {
		VStack {
			if let image = profileImage {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: 200, height: 200)
					.clipShape(Circle())
			}

			Button("Choose Photo") {
				showImagePicker = true
			}
		}
		.sheet(isPresented: $showImagePicker) {
			ImagePicker(image: $profileImage)
		}
	}
}
```
