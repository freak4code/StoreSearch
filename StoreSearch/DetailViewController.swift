//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Shahriar Nasim Nafi on 16/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var item: SearchResult!
    var downloadTask: URLSessionDownloadTask?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    deinit {
        downloadTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 10
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        if let imageBigURL = URL(string:item.imageLarge){
            downloadTask = artworkImageView.loadImage(url:imageBigURL)
        }
        nameLabel.text = item.name
        
        if item.artist.isEmpty{
            artistNameLabel.text = "Unknown"
        }else{
            artistNameLabel.text =  String(format: "%@  (%@)", item.artist, item.type)
        }
        
        kindLabel.text = item.type
        genreLabel.text = item.genre
        
        // Show price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = item.currency
        let priceText: String
        if item.price == 0 {
            priceText = "Free"
        } else if let text = formatter.string(
            from: item.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        
        
        priceButton.setTitle(priceText, for: .normal)
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func close(){
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension DetailViewController: UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

extension DetailViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
