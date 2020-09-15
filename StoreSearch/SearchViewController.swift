//
//  ViewController.swift
//  StoreSearch
//
//  Created by Shahriar Nasim Nafi on 10/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var cellNib = UINib(nibName:Constant.TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constant.TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: Constant.TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constant.TableView.CellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: Constant.TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constant.TableView.CellIdentifiers.loadingCell)
        
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        searchBar.delegate =  self
        searchBar.becomeFirstResponder()
        
        
        
    }
    
    
}


extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print("The search text is: ’\(searchBar.text!)’ \(searchResults.count)")
        searchResults = []
        if !searchBar.text!.isEmpty{
            isLoading = true
            tableView.reloadData()
            let url = iTuneURL(search: searchBar.text!)
            print(url)
            
            let queue = DispatchQueue.global()
            queue.async {
                
                if let jsonData = self.performStoreRequest(with: url){
                    self.searchResults = self.parse(from: jsonData)
                    // 1//
                    //                searchResults.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending
                    //                }
                    //2//
                    //                searchResults.sort{ $0 < $1}
                    
                    //3//
                    self.searchResults.sort(by: <)
                    DispatchQueue.main.async {
                        self.hasSearched = true
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                }
            }
            
        }
        
        
        print("Total: \(searchResults.count)")
        
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading{
            return 1
        }else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.TableView.CellIdentifiers.loadingCell,for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        }
        else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: Constant.TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            
        } else {            
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel!.text = searchResult.name
            if searchResult.artist.isEmpty{
                cell.artistNameLabel!.text = "Unknown"
            }else{
                cell.artistNameLabel!.text =  String(format: "%@  (%@)", searchResult.artist, searchResult.type)
            }
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        }
        return indexPath
    }
    
    
}


//MARK: - URL s
extension SearchViewController{
    func iTuneURL(search text: String) -> URL{
        let encodedText =  text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! // for use space and other in url
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText)
        let url = URL(string: urlString)!
        return url
    }
    
    func performStoreRequest(with url: URL) -> Data?{
        do{
            return try Data(contentsOf: url)
        }catch{
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }
    
    func parse(from data: Data) -> [SearchResult]{
        do{
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        }catch{
            print("JSON Error: \(error)")
            return []
        }
        
    }
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store. Please try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
