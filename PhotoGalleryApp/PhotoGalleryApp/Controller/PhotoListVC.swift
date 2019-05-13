//
//  PhotoListVC.swift
//  PhotoGalleryApp
//
//  Created by Kapil on 11/05/19.
//  Copyright © 2019 Incture. All rights reserved.
//

import UIKit

class PhotoListVC: UIViewController {

    // Activity Indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorHeight: NSLayoutConstraint!
    // Collection View inset
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0 , left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate var itemsPerRow: CGFloat = 2
    @IBOutlet weak var collectionView: UICollectionView!
    // Search bar
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    // Image data
    var imageListData = [Item]()
    // Instance of Image Download Manager
    let downloadService = DownloadManager()
    // Local path
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    // Url session
    lazy var downloadsSession: URLSession = {
        //    let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    // For Image count
    var downloadCnt = 0{
        didSet{
            DispatchQueue.main.async() {
                self.activityIndicatorHeight.constant = (self.downloadCnt == 0) ? 0 : 40
                self.activityIndicator.isHidden = (self.downloadCnt == 0) ? true : false
            }
        }
    }
    
    var alert : UIAlertController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        configSearchBar() 
        configCollectionView()
        downloadService.downloadsSession = downloadsSession
        activityIndicatorHeight.constant = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func configCollectionView()
    {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "ImageCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
    }
    
    func configSearchBar(){
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
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
    
    
    
    func createLabelForNoResult() -> UIView
    {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        if imageListData.count == 0
        {
            if searchBar.text == ""{
                label.text = "Please search something..."
            }
            else{
                label.text = "No result found"
            }
            
        }else
        {
            label.text = ""
        }
        
        return label
    }
    //MARK:- Network Call
    func getImageList(_ text :  String){
        showLoader("Please wait ...")
        let extendedUrl = "\(text)&;tagmode=any&format=json&nojsoncallback=1"
        NetworkCall<ImageListModel>.sendAPIRequest(requestType: RequestType.imageListUrl, header: nil,extendedUrl: extendedUrl) { (response) in
            DispatchQueue.main.async {
                self.hideLoader()
                self.searchBar.endEditing(true)
                self.searchBar.resignFirstResponder()
            }
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

            case .failed( _, _):
                self.showMessage("Error in getting the imagelist")
            }
        }
    }
    
    private func showMessage(_ msg : String)
    {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }

    func showLoader(_ msg : String){
        alert = UIAlertController(title: nil, message: msg , preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        if let alert = alert{
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func hideLoader(){
        alert?.dismiss(animated: false, completion: nil)
    }
    
}


extension PhotoListVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.collectionView.backgroundView = self.createLabelForNoResult()
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
            downloadCnt = downloadCnt + 1
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
        downloadCnt = downloadCnt - 1
        download?.image.localUrl = destinationURL.absoluteString
        if let index = download?.image.index {
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
}

