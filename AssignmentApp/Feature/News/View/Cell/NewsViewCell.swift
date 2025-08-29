//
//  NewsViewCell.swift
//  AssignmentApp
//
//  Created by Nivedita Chauhan on 26/08/25.
//

import Kingfisher
import UIKit

final class NewsViewCell: UITableViewCell {
    @IBOutlet private var articleImageView: UIImageView!
    @IBOutlet private var auther: UILabel!
    @IBOutlet private var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func loadNews(_ article: Article) {
        articleImageView.kf.setImage(with: URL(string: article.urlToImage!))
        auther.text = article.author
        title.text = article.title
    }
}
