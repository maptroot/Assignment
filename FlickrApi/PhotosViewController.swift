//
//  PhotosViewController.swift
//  FlickrApi
//
//  Created by Mark Aptroot on 23-01-17.
//  Copyright © 2017 Mark Aptroot. All rights reserved.
//

import UIKit


class PhotosViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    var selectedPhotoIndex: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        
        store.fetchRecentPhotos() {
            (photosResult) -> Void in
            
            
            OperationQueue.main.addOperation {
                switch photosResult {
                case let .Success(photos):
                    self.photoDataSource.photos = photos
                case let .Failure(error):
                    self.photoDataSource.photos.removeAll()
                    
                }
                self.collectionView.reloadData()
               // self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        
        let lastPhoto = photoDataSource.photos.count - 25
        
        
        // check if come to the last image in collectionview
        if indexPath.row == lastPhoto  {
            //print("laatste foto")
            fetch()
            
        }
        
        
        
        
        store.fetchImageForPhoto(photo: photo, size: .Small) { (result) in
            
            OperationQueue.main.addOperation {
                let photoIndex = self.photoDataSource.photos.index(of: photo)!
                let photoIndexPath = IndexPath(item: photoIndex, section: 0)
                
                
                
                
                
                if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                    cell.updateWithImage(image: photo.image)
                }
            }
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPhotoIndex =  indexPath.row
        
        self.performSegue(withIdentifier: "ShowFullScreen", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFullScreen" {
            if let destinationVC = segue.destination as? FullViewController {
                destinationVC.selectedPhotoIndex = self.selectedPhotoIndex
                destinationVC.photoDataSource = self.photoDataSource
                destinationVC.store = self.store
            }
        }
    }
    
    
    
    func fetch() {
        store.fetchRecentPhotos() {
            (photosResult) -> Void in
            
            
           OperationQueue.main.addOperation {
                switch photosResult {
                case let .Success(photos):
                    
                    for photo in photos {
                        self.photoDataSource.photos.append(photo)
                    }
                    
                    
                    
                //self.photoDataSource.photos = photos
                case let .Failure(error):
                    self.photoDataSource.photos.removeAll()
                    
                }
                self.collectionView.reloadData()
        }
        }
        
    }
    
}
