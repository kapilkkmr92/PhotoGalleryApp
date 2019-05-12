//
//  PreviewImageVC.swift
//  PhotoGalleryApp
//
//  Created by Kapil on 12/05/19.
//  Copyright © 2019 Incture. All rights reserved.
//

import UIKit

class PreviewImageVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageUrl : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if imageUrl == ""{
            imageView.image = UIImage(named: "Dummy")
        }
        else{
            imageView.image = loadUrl(fileUrl: imageUrl!)
        }
        
    }
    
}
