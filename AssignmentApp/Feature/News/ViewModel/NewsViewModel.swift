//
//  NewsViewModel.swift
//  AssignmentApp
//
//  Created by Nivedita Chauhan on 26/08/25.
//

import Foundation

final class NewsViewModel {
    private let service = NewsAPIService()
    private var currentPage = 1
    private let pageSize = 20
    private var totalResults = 0
    private var query = ""

    var articles: [Article] = [] {
        didSet { onArticlesUpdated?(articles) }
    }

    var isLoading = false
    var hasMorePages = true

    // Callbacks for UIKit
    var onArticlesUpdated: (([Article]) -> Void)?
    var onError: ((Error) -> Void)?

    // MARK: - Load Initial

    func loadInitialNews(query: String) {
        self.query = query
        currentPage = 1
        articles.removeAll()
        hasMorePages = true
        loadMoreNews()
    }

    // MARK: - Load More

    func loadMoreNews() {
        guard !isLoading, hasMorePages else { return }
        isLoading = true

        Task {
            do {
                let response = try await service.fetchNews(query: query, page: currentPage, pageSize: pageSize)

                CoreDataManager.shared.saveArticles(response.articles)

                articles.append(contentsOf: response.articles)
                totalResults = response.totalResults
                currentPage += 1
                hasMorePages = articles.count < totalResults
            } catch {
                print("API error, loading from cache:", error)
                // Load offline articles if API fails
                if articles.isEmpty {
                    articles = CoreDataManager.shared.fetchArticles()
                }
                onError?(error)
            }
            isLoading = false
        }
    }
}
