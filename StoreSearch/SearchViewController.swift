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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! // Type ⌘+Enter (without Option) to close the Assistant editor again. These are very handy keyboard shortcuts to remembe
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    var dataTask: URLSessionDataTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var cellNib = UINib(nibName:Constant.TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constant.TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: Constant.TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constant.TableView.CellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: Constant.TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constant.TableView.CellIdentifiers.loadingCell)
        
        
        tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        searchBar.delegate =  self
        searchBar.becomeFirstResponder()
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: segmentColor]
        segmentedControl.selectedSegmentTintColor = segmentColor
        segmentedControl.setTitleTextAttributes(normalTextAttributes,for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes,for: .selected)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .highlighted)
        
        
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    
}


extension SearchViewController: UISearchBarDelegate{
    
    
    func performSearch() {
        searchBar.resignFirstResponder()
        print("The search text is: ’\(searchBar.text!)’ \(searchResults.count)")
        searchResults = []
        if !searchBar.text!.isEmpty{
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            let url = iTuneURL(search: searchBar.text!,category: segmentedControl.selectedSegmentIndex)
            print(url)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url) { (data, response, error) in
                if let error = error as NSError?, error.code == -999{
                    return
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data{
                        self.searchResults = self.parse(from: data)
                        self.searchResults.sort(by: < )
                        print("On main thread \(Thread.current.isMainThread ? "Yes" : "No")")
                        DispatchQueue.main.async {
                            self.hasSearched = true
                            self.isLoading = false
                            self.tableView.reloadData()
                            print("On main thread \(Thread.current.isMainThread ? "Yes" : "No")")
                        }
                        return
                        
                    }
                    
                } else {
                    print("Failure! \(response!)")
                }
                
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
                
                
            }
            
            dataTask?.resume()
            
            
            
            
        }
        
        
        print("Total: \(searchResults.count)")
        
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    
        
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
            cell.configure(for: searchResult)
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        }
        return indexPath
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            let destination = segue.destination as! DetailViewController
            destination.item = searchResults[(sender as! IndexPath).row]
        }
    }
    
    
}


//MARK: - URL s
extension SearchViewController{
    func iTuneURL(search text: String, category: Int = 1) -> URL{
        let kind: String
        switch category {
            case 1: kind = "musicTrack"
            case 2: kind = "software"
            case 3: kind = "ebook"
            default: kind = ""
        }
        let encodedText =  text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! // for use space and other(s) in url
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=\(kind)", encodedText)
        let url = URL(string: urlString)!
        return url
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
