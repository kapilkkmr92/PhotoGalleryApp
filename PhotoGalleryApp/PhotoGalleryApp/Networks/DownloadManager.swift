//
//  DownloadManager.swift
//  PhotoGalleryApp
//
//  Created by Kapil on 12/05/19.
//  Copyright © 2019 Incture. All rights reserved.
//

import Foundation

class DownloadManager {
//    static let shared : DownloadManager = DownloadManager()
//    let defaultSession = URLSession(configuration: .default)
//    let dataTask : URLSessionDataTask?
//    var activeDownloads: [URL: Download] = [:]
//
    
    var downloadsSession: URLSession!
    var activeDownloads: [URL: Download] = [:]
    
    // MARK: - Download methods called by TrackCell delegate methods
    
    func startDownload(_ track: Item) {
        // 1
        if track.downloaded == false{
            let download = Download(image: track)
            // 2
            if let url = track.media?.m{
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


//extension DownloadManager : URLSessionDownloadDelegate{
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        print("Finished downloading to \(location).")
//    }
//
//
//    func startDownload(_ url: String) {
//        // 1
//        let download = Download(track: track)
//        // 2
//        download.task = downloadsSession.downloadTask(with: url)
//        // 3
//        download.task!.resume()
//        // 4
//        download.isDownloading = true
//        // 5
//        activeDownloads[download.track.previewURL] = download
//    }
//}


