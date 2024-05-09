//
//  BookModel.swift
//  Jinmoon'sLibrary
//
//  Created by 최진문 on 2024/05/02.
//

import Foundation

struct SearchResults: Codable {
    let documents: [Book]
}

struct Book: Codable {
    let title: String
    let contents: String
    let url: String
    let authors: [String]
    let price: Int
    let thumbnail: String
}

class SharedDataModel {
    
    static let shared = SharedDataModel()
    var books: [Book] = []
    var recentSelectedBooks: [Book] = []
    
    private init() {}
}
