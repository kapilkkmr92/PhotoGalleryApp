//
//  PhotoListVC.swift
//  PhotoGalleryApp
//
//  Created by Kapil on 11/05/19.
//  Copyright © 2019 Incture. All rights reserved.
//

import UIKit

class PhotoListVC: UIViewController {

    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0 , left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate var itemsPerRow: CGFloat = 1
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    var imageListData = [Item]()
    let downloadService = DownloadManager()
    var cache : NSCache<AnyObject, AnyObject>!
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    lazy var downloadsSession: URLSession = {
        //    let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cache = NSCache()
        collectionView.delegate = self
        collectionView.dataSource = self
        downloadService.downloadsSession = downloadsSession
        let nib = UINib(nibName: "ImageCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
        getImageList("cat")
        
    }
   
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    
    @IBAction func onOptionBtnPress(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        actionSheet.addAction(UIAlertAction(title: "2", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.itemsPerRow = 2
            self.collectionView.reloadData()
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "3", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.itemsPerRow = 3
            self.collectionView.reloadData()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "4", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.itemsPerRow = 4
            self.collectionView.reloadData()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    func getImageList(_ text :  String){
        let extendedUrl = "\(text)&;tagmode=any&format=json&nojsoncallback=1"
        OnBoardingService<ImageListModel>.sendAPIRequest(requestType: RequestType.imageListUrl, header: nil,extendedUrl: extendedUrl) { (response) in
            switch response {
            case .success(let result):
                self.imageListData =  result?.items ?? []
                var index = 0
                for items in self.imageListData{
                    items.index = index
                    items.downloaded = false
                    index = index + 1
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
//                self.categoryListData = result
                
            case .failed( _, _):
                print("Error")
            }
        }
    }

}


extension PhotoListVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return imageListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let item = imageListData[indexPath.row]
        if item.localUrl == ""{
            downloadService.startDownload(item)
            cell.imageView.image = UIImage(named: "Dummy")
        }
        else{
            cell.imageView.image = loadUrl(fileUrl: item.localUrl!)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        searchBar.resignFirstResponder()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "PreviewImageVC") as! PreviewImageVC
        
        let item = imageListData[indexPath.row]
        controller.imageUrl = item.localUrl
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
}


extension PhotoListVC : UISearchBarDelegate{
    
    func searchBarIsEmpty() -> Bool {
        
        return searchBar.text?.isEmpty ?? true
        
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        print("searching")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getImageList(searchBar.text ?? "" )
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.searchBar.text = ""
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
}


extension PhotoListVC : URLSessionDownloadDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download?.image.downloaded = true
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        download?.image.localUrl = destinationURL.absoluteString
//        print(download?.image.index)
        if let index = download?.image.index {
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
}

