# Async Operation Patterns

## Task Modifier

**Use for:** Loading data when view appears

```swift
struct ArticleDetailView: View {
  let articleID: String
  
  @SwiftUI.State
  private var article: Article?
  
  @SwiftUI.State
  private var isLoading: Bool = true
  
  init(
    articleID: String
  ) {
    self.articleID = articleID
  }

  var body: some View {
    Group {
      if let article {
        ArticleContent(article: article)
      } else if isLoading {
        ProgressView()
      } else {
        ContentUnavailableView(
          "Article Not Found",
          systemImage: "doc.text"
        )
      }
    }
    .task { await loadArticle() }
  }

  private func loadArticle() async {
    isLoading = true
    defer { isLoading = false }

    await withErrorReporting {
      self.article = try await articleService.fetchArticle(id: articleId)
    }
  }
}
```

## Refreshable Content

**Use for:** Pull-to-refresh lists

```swift
struct ArticleListView: View {
  @SwiftUI.State
  private var articles: [Article] = []

  var body: some View {
    List(articles) { article in
      ArticleRow(article: article)
    }
    .refreshable { await refreshArticles() }
  }

  private func refreshArticles() async {
    await withErrorReporting {
      self.articles = try await articleService.fetchArticles()
    }
  }
}
```

## Background Tasks

**Use for:** Non-blocking async operations

```swift
struct ArticleDetailView: View {
  let article: Article

  @SwiftUI.State
  private var isSaved = false

  init(
    article: Article
  ) {
    self.article = article
  }

  var body: some View {
    ArticleContent(article: article)
      .toolbar {
        Button(isSaved ? "Saved" : "Save") {
          Task { await saveArticle() }
        }
      }
  }

  private func saveArticle() async {
    await withErrorReporting {
      try await articleService.saveArticle(article)
      isSaved = true
    }
  }
}
```
