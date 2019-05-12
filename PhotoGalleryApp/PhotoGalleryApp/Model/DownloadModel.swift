//
//  DownloadModel.swift
//  PhotoGalleryApp
//
//  Created by Kapil on 12/05/19.
//  Copyright © 2019 Incture. All rights reserved.
//

import Foundation
class Download {
    
    var image: Item
    init(image: Item) {
        self.image = image
    }
    // Download service sets these values:
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    // Download delegate sets this value:
    var progress: Float = 0
}
