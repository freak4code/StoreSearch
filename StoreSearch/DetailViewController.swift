//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Shahriar Nasim Nafi on 16/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var item: SearchResult!{
        didSet{
            if isViewLoaded{
                updateUI()
            }
        }
    }
    var downloadTask: URLSessionDownloadTask?
    
    var dismissStyle = AnimationStyle.fade
    
    var isPopup = false
    
    
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
        
        view.backgroundColor = UIColor.clear
        if traitCollection.userInterfaceStyle == .light{
            view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
            
        }else{
            view.tintColor = UIColor(red: 140/255, green: 140/255, blue: 240/255, alpha: 1)
        }
        popupView.layer.cornerRadius = 10
        
        if isPopup{
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            updateUI()
        }else{
            view.backgroundColor = UIColor(patternImage:
                UIImage(named: "LandscapeBackground")!)
            popupView.isHidden = true
            if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String{
                title = displayName
            }
        }
        
        
    }
    
    @IBAction func close(){
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
        
    }
    
    func updateUI(){
        
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
        
        popupView.isHidden = false
        
    }
    
    
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowMenu" {
            let destination = segue.destination as! MenuViewController
            destination.delegate = self
        }
    }
    
    
}

extension DetailViewController: UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .fade:
            return FadeOutAnimationController()
        case .slide:
            return SlideOutAnimationController()
        }
    }
    
    
}

extension DetailViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}

//MARK: - Dismiss Type
extension DetailViewController{
    
    enum AnimationStyle{
        case slide , fade
    }
}


extension DetailViewController: MenuViewControllerDelegate {
    func menuViewControllerSendEmail(_ controller: MenuViewController) {
        dismiss(animated: true){
            if MFMailComposeViewController.canSendMail() {
                let controller = MFMailComposeViewController()
                controller.mailComposeDelegate = self
                controller.modalPresentationStyle = .formSheet
                controller.setSubject(NSLocalizedString("Support Request",comment: "Email subject"))
                controller.setToRecipients(["info@snnsystems.com"])
                self.present(controller, animated: true, completion: nil)
            }
            
        }
    }
    
}

extension DetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
