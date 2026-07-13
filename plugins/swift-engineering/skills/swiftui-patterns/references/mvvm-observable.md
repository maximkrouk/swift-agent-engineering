# MVVM with @Observable (iOS 17+)

**Use for:** View models with reactive state

**Problem:** Need reactive view models without @Published boilerplate.

**Solution:**
```swift
import Observation

@Observable
@MainActor
final class ArticleListViewModel {
  var articles: [Article]
  var isLoading: Bool
  var errorMessage: String?
  
  private let articleService: ArticleService

  public init(
    articles: [Article] = []
    isLoading: Bool = false
    errorMessage: String? = nil,
    articleService: ArticleService
  ) {
    self.articles = articles
    self.isLoading = isLoading
    self.errorMessage = errorMessage
    self.articleService = articleService
  }

  func loadArticles() async {
    isLoading = true
    defer { isLoading = false }
    
    errorMessage = nil

    do {
      articles = try await articleService.fetchArticles()
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}

struct ArticleListView: View {
  @SwiftUI.State
  private var viewModel: ArticleListViewModel

  init(
    _ viewModel: ArticleListViewModel
  ) {
    _viewModel = State(wrappedValue: viewModel)
  }

  var body: some View {
    List(viewModel.articles) { article in
      ArticleRow(article: article)
    }
    .overlay {
      if viewModel.isLoading {
        ProgressView()
      }
    }
    .alert(
      "Error", 
      isPresented: .constant(viewModel.errorMessage != nil)
    ) {
      Button("OK") { viewModel.errorMessage = nil }
    } message: {
      if let message = viewModel.errorMessage {
        Text(message)
      }
    }
    .task {
      await viewModel.loadArticles()
    }
  }
}
```

**Benefits:**
- No `@Published` needed
- Fine-grained observation (only tracks accessed properties)
- Better performance than ObservableObject
- Less boilerplate

> [!Note]
> 
> Prefer [`swift-navigation`](https://github.com/pointfreeco/swift-navigation) APIs over plain SwiftUI for managing presentation including alerts