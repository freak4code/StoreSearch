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
    
    var landscapeVC: LandscapeViewController?
    weak var splitViewDetail: DetailViewController?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! // Type ⌘+Enter (without Option) to close the Assistant editor again. These are very handy keyboard shortcuts to remembe
    
    
    private let search = Search()
    
    
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        switch newCollection.verticalSizeClass {
        //When an iPhone app is in portrait orientation, the horizontal size class is compact and the vertical size class is regular. sometimes horizontal size class remians compact in any conditions
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        @unknown default:
            fatalError()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = NSLocalizedString("Search", comment: "split view master button")
        
        var cellNib = UINib(nibName:Constant.TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constant.TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: Constant.TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constant.TableView.CellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: Constant.TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constant.TableView.CellIdentifiers.loadingCell)
        
        
        tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        searchBar.delegate =  self
        if UIDevice.current.userInterfaceIdiom != .pad{
            searchBar.becomeFirstResponder()
        }
        
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
        search.performSearch(for: searchBar.text!, category: Search.Category(rawValue: segmentedControl.selectedSegmentIndex)!){
            success in
            if !success{
                self.showNetworkError()
            }
            self.tableView.reloadData()
            self.landscapeVC?.searchResultsReceived()
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
        
        
        
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
        
        switch search.state {
        case .loading:
            return 1
        case .notSearchedYet:
            return 0
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .notSearchedYet:
            fatalError()
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: Constant.TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
        
        
        
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact{
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        }else{
            if case .results(let list) = search.state{
                splitViewDetail?.item = list[indexPath.row]
                if self.splitViewController!.displayMode != .allVisible{
                    hideMasterPane()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .loading, .noResults, .notSearchedYet:
            return nil
        case .results:
            return indexPath
        }
        
    }
    
    private func hideMasterPane(){
        UIView.animate(withDuration: 0.25, animations: {
            self.splitViewController!.preferredDisplayMode = .primaryHidden
        }) { _ in
            self.splitViewController!.preferredDisplayMode = .automatic
        }
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            let destination = segue.destination as! DetailViewController
            if case .results(let list) = search.state{
                destination.item = list[(sender as! IndexPath).row]
                destination.isPopup = true
            }
            
        }
    }
    
    
}


//MARK: - URL s
extension SearchViewController{
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store. Please try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
}

//MARK: - Landscape View

extension SearchViewController{
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator){
        guard landscapeVC == nil  else {return}
        landscapeVC = storyboard!.instantiateViewController(identifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeVC{
            controller.search = search
            controller.view.frame =  view.bounds
            controller.view.alpha = 0
            view.addSubview(controller.view)
            addChild(controller)
            coordinator.animate(alongsideTransition: { _ in
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil{
                    self.dismiss(animated: true, completion: nil)
                }
                controller.view.alpha = 1
            }) { _ in
                self.didMove(toParent: self)
            }
        }
        
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator){
        if let controller = landscapeVC{
            controller.willMove(toParent: nil)
            coordinator.animate(alongsideTransition: {
                _ in
                controller.view.alpha = 0
                if self.presentedViewController != nil{
                    self.dismiss(animated: true, completion: nil)
                }
                
            }, completion: {
                _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            })
        }
    }
}
