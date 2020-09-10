//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Shahriar Nasim Nafi on 11/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import Foundation

class SearchResult{
    var name: String
    var artistName: String
    
    init() {
        name = ""
        artistName = ""
    }
    
    init(name: String, artistName: String) {
        self.name = name
        self.artistName = artistName
    }
}
