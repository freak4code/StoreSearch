//
//  Search.swift
//  StoreSearch
//
//  Created by Shahriar Nasim Nafi on 20/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import Foundation

class Search{
    
    
    typealias SearchComplete = (Bool) -> ()
    
    private(set) var state: State = .notSearchedYet
    
    private var dataTask: URLSessionDataTask? = nil
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        print("Searching...")
        if !text.isEmpty {
            dataTask?.cancel()
//            isLoading = true
//            hasSearched = true
//            searchResults = []
            state = .loading
            
            let url = iTunesURL(search: text, category: category)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url){
                data, response, error in
                // Was the search cancelled?
                var newState = State.notSearchedYet
                var success = false
                if let error = error as NSError?, error.code == -999 {
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                    var searchResults = self.parse(from: data)
//                    self.searchResults.sort(by: <)
//                    print("Success!")
//                    self.isLoading = false
                    if searchResults.isEmpty{
                        newState = .noResults
                    }else{
                        searchResults.sort(by: <)
                        newState = .results(searchResults)
                    }
                    success = true
                }
                
//                if !success {
//                    print("Failure! \(response!)")
//                    self.hasSearched = false
//                    self.isLoading = false
//                }
                
                DispatchQueue.main.async {
       
                    self.state = newState
                    completion(success)
                    
                }
                
                
            }
            
            dataTask?.resume()
            
        }
    }
    
    
    private func iTunesURL(search text: String, category: Category = .all) -> URL{
        let kind = category.type
        let encodedText =  text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! // for use space and other(s) in url
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=\(kind)", encodedText)
        let url = URL(string: urlString)!
        return url
    }
    
    
    
    private func parse(from data: Data) -> [SearchResult]{
        do{
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        }catch{
            print("JSON Error: \(error)")
            return []
        }
        
    }
    
    enum Category: Int{
        case all = 0 , music , software, ebooks
        var type: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }            
        }
        
    }
    
    
    enum State {
      case notSearchedYet
      case loading
      case noResults
      case results([SearchResult])
    }
    
}


//searchBar.resignFirstResponder()
//print("The search text is: ’\(searchBar.text!)’ \(searchResults.count)")
//searchResults = []
//if !searchBar.text!.isEmpty{
//    dataTask?.cancel()
//    isLoading = true
//    tableView.reloadData()
//    let url = iTuneURL(search: searchBar.text!,category: segmentedControl.selectedSegmentIndex)
//    print(url)
//    let session = URLSession.shared
//    dataTask = session.dataTask(with: url) { (data, response, error) in
//        if let error = error as NSError?, error.code == -999{
//            return
//        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//            if let data = data{
//                self.searchResults = self.parse(from: data)
//                self.searchResults.sort(by: < )
//                print("On main thread \(Thread.current.isMainThread ? "Yes" : "No")")
//                DispatchQueue.main.async {
//                    self.hasSearched = true
//                    self.isLoading = false
//                    self.tableView.reloadData()
//                    print("On main thread \(Thread.current.isMainThread ? "Yes" : "No")")
//                }
//                return
//
//            }
//
//        } else {
//            print("Failure! \(response!)")
//        }
//
//        DispatchQueue.main.async {
//            self.hasSearched = false
//            self.isLoading = false
//            self.tableView.reloadData()
//            self.showNetworkError()
//        }
//
//
//    }
//
//    dataTask?.resume()
//
//
//
//
//}
//
//
//print("Total: \(searchResults.count)")
//
