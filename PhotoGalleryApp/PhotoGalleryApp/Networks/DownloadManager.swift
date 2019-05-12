//
//  DownloadManager.swift
//  PhotoGalleryApp
//
//  Created by Kapil on 12/05/19.
//  Copyright © 2019 Incture. All rights reserved.
//

import Foundation

class DownloadManager {
    
    var downloadsSession: URLSession!
    var activeDownloads: [URL: Download] = [:]
    func startDownload(_ image: Item) {
        // 1
        if image.downloaded == false{
            let download = Download(image: image)
            // 2
            if let url = image.media?.m{
                download.task = downloadsSession.downloadTask(with: url)
                // 3
                download.task!.resume()
                // 4
                download.isDownloading = true
                // 5
                activeDownloads[url] = download
            }
        }
        
    }
}

