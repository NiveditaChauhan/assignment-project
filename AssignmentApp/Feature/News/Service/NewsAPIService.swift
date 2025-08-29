//
//  NewsAPIService.swift
//  AssignmentApp
//
//  Created by Nivedita Chauhan on 26/08/25.
//

import Foundation

final class NewsAPIService {
    private let apiKey = "e5fd239eb8974d17bfc1efa8b80ed39d"
    private let baseURL = "https://newsapi.org/v2/everything"

    /// Fetches news articles with pagination
    func fetchNews(
        query: String = "Tech",
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> NewsResponse {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200 ..< 300 ~= httpResponse.statusCode
        else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(NewsResponse.self, from: data)
    }
}
