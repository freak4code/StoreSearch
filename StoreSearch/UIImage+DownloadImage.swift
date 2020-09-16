//
//  UIImage+DownloadImage.swift
//  StoreSearch
//
//  Created by Shahriar Nasim Nafi on 16/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit

extension UIImageView{
    func  loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url) { [weak self] (url, response, error) in
            if error == nil , let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data){
                DispatchQueue.main.async {
                    if let wealSelf = self{
                        wealSelf.image = image
                    }
                }
            }
            
            
        }
        downloadTask.resume()
        return downloadTask
    }
}
