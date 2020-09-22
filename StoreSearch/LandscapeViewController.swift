//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Shahriar Nasim Nafi on 20/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    private var firstTime = true
    private var downloads = [URLSessionDownloadTask]()
    
    var search = Search()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Remove constraints from main view
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints for page control
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints for scroll view
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        
        pageControl.numberOfPages = 0
        scrollView.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    
    deinit {
        downloads.forEach{$0.cancel()}
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = view.safeAreaLayoutGuide.layoutFrame
        pageControl.frame = CGRect(x: safeFrame.origin.x,
                                   y: safeFrame.size.height - pageControl.frame.size.height, width: safeFrame.size.width,
                                   height: pageControl.frame.size.height)
        if firstTime{
            firstTime = false
            switch search.state {
            case .loading:
                showSpinner()
            case .noResults:
                showNothingFoundLabel()
            case .notSearchedYet:
                break
            case .results(let list):
                tileButtons(list)
                
                
            }
            
        }
    }
    
    
    
    private func tileButtons(_ searchResults: [SearchResult]){
        var columnsPerPage = 6
        var rowsPerPage = 3
        var itemWidth: CGFloat = 94
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 2
        var marginY: CGFloat = 20
        
        let viewWidth = scrollView.bounds.size.width
        
        switch viewWidth {
        case 568:
            // 4-inch device
            break
        case 667:
            // 4.7-inch device
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736:
            // 5.5-inch device
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
            marginX = 0
        case 724:
            // iPhone X
            columnsPerPage = 8
            rowsPerPage = 3
            itemWidth = 90
            itemHeight = 98
            marginX = 2
            marginY = 29
            
        default:
            break
        }
        
        // Button size
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        
        var row = 0
        var column = 0
        var x = marginX
        print("Total: \(searchResults.count)")
        for (index, result) in searchResults.enumerated() {
            // 1
            let button = UIButton(type: .custom)
            button.tag = 2000 + index
            button.addTarget(self, action: #selector(showDetail), for: .touchUpInside)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            let download = downloadImage(for: result, andPlaceOn: button)
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + CGFloat(row)*itemHeight + paddingVert,
                                  width: buttonWidth, height: buttonHeight)
            // 3
            scrollView.addSubview(button)
            // 4
            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
            
        }
        
        // Set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages) * viewWidth, height: scrollView.bounds.size.height)
        print("Number of pages: \(numPages)")
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        
        // TODO: more to come here
        
        
    }
    
    private func downloadImage(for searchResult: SearchResult,
                               andPlaceOn button: UIButton){
        if let url = URL(string: searchResult.imageSmall) {
            let task = URLSession.shared.downloadTask(with: url) {
                [weak button] url, response, error in
                if error == nil, let url = url,
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(image, for: .normal) }
                    } }
            }
            task.resume()
            downloads.append(task)
            
            
        }
    }
    
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = CGPoint(x: view.bounds.midX + 0.5,y: view.bounds.midY + 0.5)
        spinner.tag = 10000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    private func hideSpinner() {
        view.viewWithTag(10000)?.removeFromSuperview() }
    
    func searchResultsReceived() {
        hideSpinner()
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            break
        case .results(let list):
            tileButtons(list)
        }
    }
    
    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Nothing Found"
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.sizeToFit()
        var rect = label.frame
        rect.size.width = ceil(rect.size.width/2) * 2
        rect.size.height = ceil(rect.size.height/2) * 2 // make even label.frame = rect
        label.center = CGPoint(x: scrollView.bounds.midX,y: scrollView.bounds.midY)
        view.addSubview(label)
        
    }
    
    @objc func showDetail(_ sender:UIButton){
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
    
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! DetailViewController
            if case .results(let list) = search.state {
                destination.item = list[(sender as! UIButton).tag - 2000]
            }
            
        }
    }
    
}


//MARK: - ScrollView Delegate

extension LandscapeViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = page
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.scrollView.contentOffset = CGPoint(
                x: self.scrollView.bounds.size.width *
                    CGFloat(sender.currentPage), y: 0)
        }, completion: nil)
    }
    
    
}
