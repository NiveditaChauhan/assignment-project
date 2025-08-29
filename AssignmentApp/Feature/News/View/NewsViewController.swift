//
//  ViewController.swift
//  AssignmentApp
//
//  Created by Nivedita Chauhan on 26/08/25.
//

import UIKit

final class NewsViewController: UITableViewController, UISearchResultsUpdating {
    private let viewModel = NewsViewModel()
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentQuery: String = "Tech"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"

        tableView.register(.init(nibName: "NewsViewCell", bundle: nil), forCellReuseIdentifier: "NewsViewCell")

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search News"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

        viewModel.onArticlesUpdated = { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }

        viewModel.onError = { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
        }

        if NetworkMonitor.shared.isConnected {
            viewModel.loadInitialNews(query: currentQuery)
        } else {
            viewModel.articles = CoreDataManager.shared.fetchArticles()
        }
    }

    // MARK: - Pull to Refresh

    @objc private func handleRefresh() {
        viewModel.loadInitialNews(query: currentQuery)
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        currentQuery = query
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: query, afterDelay: 0.5)
    }

    @objc private func performSearch(_ query: String) {
        viewModel.loadInitialNews(query: query)
    }

    // MARK: - TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = viewModel.articles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsViewCell", for: indexPath) as! NewsViewCell
        cell.loadNews(article)
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.articles.count - 1 {
            if NetworkMonitor.shared.isConnected {
                viewModel.loadMoreNews()
            }
        }
    }
}
