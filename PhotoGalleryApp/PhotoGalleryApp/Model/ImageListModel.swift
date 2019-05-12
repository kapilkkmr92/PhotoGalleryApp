//
//  ImageListModel.swift
//  PhotoGalleryApp
//
//  Created by Kapil on 12/05/19.
//  Copyright © 2019 Incture. All rights reserved.
//

import Foundation
class ImageListModel: Codable {
    let title: String?
    let link: String?
    let description: String?
    let modified: String?
    let generator: String?
    let items: [Item]?
    
    init(title: String?, link: String?, description: String?, modified: String?, generator: String?, items: [Item]?) {
        self.title = title
        self.link = link
        self.description = description
        self.modified = modified
        self.generator = generator
        self.items = items
    }
}

class Item: Codable {
    let title: String?
    let link: String?
    let media: Media?
    let dateTaken: String?
    let description: String?
    let published: String?
    let author, authorID, tags: String?
    var index: Int = 0
    var downloaded = false
    var imgUrl = URL(string: "https://appharbor.com/assets/images/stackoverflow-logo.png")
    var localUrl : String? = ""
    enum CodingKeys: String, CodingKey {
        case title, link, media
        case dateTaken = "date_taken"
        case description, published, author
        case authorID = "author_id"
        case tags
    }
    
    init(title: String?, link: String?, media: Media?, dateTaken: String?, description: String?, published: String?, author: String?, authorID: String?, tags: String?) {
        self.title = title
        self.link = link
        self.media = media
        self.dateTaken = dateTaken
        self.description = description
        self.published = published
        self.author = author
        self.authorID = authorID
        self.tags = tags
    }
}

class Media: Codable {
    let m: URL?
    
    init(m: URL?) {
        self.m = m
    }
}
