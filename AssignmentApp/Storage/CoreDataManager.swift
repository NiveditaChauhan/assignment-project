//
//  CoreDataManager.swift
//  AssignmentApp
//
//  Created by Nivedita Chauhan on 26/08/25.
//

import CoreData
import Foundation
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("CoreData save error:", error)
            }
        }
    }

    func saveArticles(_ articles: [Article]) {
        let fetchRequest: NSFetchRequest<NewsArticleEntity> = NewsArticleEntity.fetchRequest()

        for article in articles {
            fetchRequest.predicate = NSPredicate(format: "id == %@", article.id)

            do {
                let results = try context.fetch(fetchRequest)

                let entity: NewsArticleEntity
                if let existing = results.first {
                    entity = existing
                } else {
                    entity = NewsArticleEntity(context: context)
                    entity.id = article.id
                }

                entity.title = article.title
                entity.author = article.author
                entity.desc = article.description
                entity.url = article.url
                entity.urlToImage = article.urlToImage
                entity.publishedAt = ISO8601DateFormatter().date(from: article.publishedAt) ?? Date()
                entity.content = article.content

            } catch {
                print("\(error)")
            }
        }

        saveContext()
    }

    func fetchArticles() -> [Article] {
        let request: NSFetchRequest<NewsArticleEntity> = NewsArticleEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]

        do {
            let results = try context.fetch(request)
            return results.map {
                Article(
                    source: nil,
                    author: $0.author,
                    title: $0.title ?? "",
                    description: $0.desc,
                    url: $0.url ?? "",
                    urlToImage: $0.urlToImage,
                    publishedAt: ISO8601DateFormatter().string(from: $0.publishedAt ?? Date()),
                    content: $0.content
                )
            }
        } catch {
            print("Fetch error:", error)
            return []
        }
    }

    func clearArticles() {
        let fetch: NSFetchRequest<NSFetchRequestResult> = NewsArticleEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            print("Failed to clear:", error)
        }
    }
}
