//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Shahriar Nasim Nafi on 11/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import Foundation

class ResultArray: Codable{
    var resultCount = 0
    var results = [SearchResult]()
    
    
}

class SearchResult: Codable, CustomStringConvertible{
    
    var artistName: String? = ""
    var trackName: String? = ""
    var kind: String? = ""
    var trackPrice: Double? = 0.0
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    var trackViewUrl: String?
    var collectionName: String?
    var collectionViewUrl: String?
    var collectionPrice: Double?
    var itemPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?
    
    
    var name: String{
        trackName ?? collectionName ?? ""
    }
    
    var storeUrl: String{
        trackViewUrl ?? collectionViewUrl ?? ""
    }
    
    var price: Double{
        trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    
    var genre: String{
        if let genre = itemGenre{
            return genre
        }else if let  genres = bookGenre{
            return genres.joined(separator: ", ")
        }
        return ""
    }
    
    var type: String{
        let kind = self.kind ?? "audioBook"
        switch kind {
        case "album":
            return NSLocalizedString("Album", comment: "Localized kind: Album")
        case "audiobook":
            return NSLocalizedString("Audio Book", comment: "Localized kind: Audio Book")
        case "book":
            return NSLocalizedString("Book", comment: "Localized kind: Book")
        case "ebook":
            return NSLocalizedString("E-Book", comment: "Localized kind: E-Book")
        case "feature-movie":
            return NSLocalizedString("Movie", comment: "Localized kind: Movie")
        case "music-video":
            return NSLocalizedString("Music Video", comment: "Localized kind: Music Video")
        case "podcast":
            return NSLocalizedString("Podcast", comment: "Localized kind: Podcast")
        case "software":
            return NSLocalizedString("App", comment: "Localized kind: App")
        case "song":
            return NSLocalizedString("Song", comment: "Localized kind: Song")
        case "tv-episode":
            return NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode")
        default:
            break
            
        }
        return "Unknown"
    }
    
    var artist: String{
        artistName ?? ""
    }
    
    var description: String{
        "Kind: \(kind ?? "None") Name: \(name), Artist Name: \(artistName ?? "None")"
    }
    
    
    
    enum CodingKeys: String, CodingKey{
        
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
        
    }
    
    
    
    
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool{
    lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
   }
