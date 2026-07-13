# Performance Optimization Patterns

## Lazy Loading

**Use for:** Long scrollable lists

```swift
// Bad: Loads all items immediately
ScrollView {
  VStack {
    ForEach(articles) { article in
      ArticleCard(article: article)
    }
  }
}

// Good: Loads items on-demand
ScrollView {
  LazyVStack(spacing: 16) {
    ForEach(articles) { article in
      ArticleCard(article: article)
        .onAppear {
          // Pagination trigger
          if article == articles.last {
            loadMoreArticles()
          }
      }
    }
  }
}
```

## View Identity

**Use for:** Efficient list rendering

```swift
// Ensure all items are Identifiable
struct Article: Identifiable {
  let id: String
  let title: String
  
  init(
    id: String,
    title: String = ""
  ) {
    self.id = id
    self.title = title
  }
}

// SwiftUI can efficiently diff changes
ForEach(articles) { article in
  ArticleRow(article: article)
}

// Or provide manual ID
ForEach(articles, id: \.id) { article in
  ArticleRow(article: article)
}
```

## Equatable Views

**Use for:** Skipping unnecessary re-renders

```swift
struct ArticleRow: View, Equatable {
  static func == (lhs: ArticleRow, rhs: ArticleRow) -> Bool {
    lhs.article.id == rhs.article.id
  }

  let article: Article
  
  init(
    article: Article
  ) {
    self.article = article
  }

  var body: some View {
    HStack {
      Text(article.title)
      Spacer()
      Text(article.author)
        .foregroundColor(.secondary)
    }
  }
}

// Usage: SwiftUI skips re-rendering if article ID unchanged
ForEach(articles) { article in
  ArticleRow(article: article)
    .equatable()
}
```

## Debounced Search

**Use for:** Search fields with live filtering

```swift
@Observable
@MainActor
final class SearchViewModel {
  var searchText: String
  var results: [Article]

  private var searchTask: Task<Void, Never>?
  
  init(
    searchText: String = "",
    results: [Article] = []
  ) {
    self.searchText = searchText
    self.results = results
  }

  func updateSearch(_ text: String) {
    self.searchText = text

    self.searchTask?.cancel()
    self.searchTask = Task {
      try? await Task.sleep(for: .milliseconds(300))
      guard !Task.isCancelled
      else { return }

      self.results = await self.performSearch(text)
    }
  }

  private func performSearch(_ query: String) async -> [Article] {
    // Search logic
    []
  }
}

struct SearchView: View {
  @SwiftUI.State
  private var viewModel: SearchViewModel = .init()

  var body: some View {
    VStack {
      TextField("Search", text: self.$viewModel.searchText)
        .onChange(of: self.viewModel.searchText) { oldValue, newValue in
          self.viewModel.updateSearch(newValue)
        }

      List(self.viewModel.results) { article in
        ArticleRow(article: article)
      }
    }
  }
}
```
