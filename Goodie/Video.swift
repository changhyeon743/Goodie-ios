//
//  Video.swift
//  Goodie
//
//  Created by 이창현 on 21/09/2019.
//  Copyright © 2019 이창현. All rights reserved.
//

import Foundation

//{
//    "title": "string",
//    "publisher": "string",
//    "publishedDate": "string",
//    "youtubeId": "string",
//    "thumbnail": "string",
//    "createdDate": "string",
//    "tags": "string",
//    "viewCount": 0,
//    "likeCount": 0,
//    "dislikeCount": 0,
//    "commentCount": 0,
//    "embedHtml": "string"
//}

struct Video :Codable{
    var title: String?
    var publisher: String?
    var publishedDate: String?
    var youtubeId: String?
    var thumbnail: String?
    var createdDate: String?
    var tags: String?
    var viewCount: Int32?
    var likeCount: Int?
    var dislikeCount: Int?
    var commentCount: Int?
    var embedHtml: String?
    
    
    
    private enum CodingKeys: String, CodingKey {
        case title
        case publisher
        case publishedDate
        case youtubeId
        case thumbnail
        case tags
        case viewCount
        case likeCount
        case dislikeCount
        case commentCount
        case embedHtml
    }
}
