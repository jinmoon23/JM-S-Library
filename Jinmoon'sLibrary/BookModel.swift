//
//  BookModel.swift
//  Jinmoon'sLibrary
//
//  Created by 최진문 on 2024/05/02.
//

import Foundation

struct SearchResults: Codable {
    let documents: [Book]
//    let meta: [Meta]
}

struct Book: Codable {
    let title: String
    let contents: String
    let url: String
    let authors: [String]
    let price: Int
    let thumbnail: String
}

//class Meta: Codable {
//    let isEnd: Bool
//    let pageableCount, totalCount: Int
//
//    enum CodingKeys: String, CodingKey {
//        case isEnd = "is_end"
//        case pageableCount = "pageable_count"
//        case totalCount = "total_count"
//    }
//
//    init(isEnd: Bool, pageableCount: Int, totalCount: Int) {
//        self.isEnd = isEnd
//        self.pageableCount = pageableCount
//        self.totalCount = totalCount
//    }
//}

class SharedDataModel {
    
    static let shared = SharedDataModel()
    var books: [Book] = []
    var recentSelectedBooks: [Book] = []
    
    private init() {}
}
