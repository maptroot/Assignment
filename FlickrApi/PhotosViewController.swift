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
        
        // get photos
        store.fetchRecentPhotos() {
            (photosResult) -> Void in
            
            // Use main thread
            OperationQueue.main.addOperation {
                switch photosResult {
                case let .Success(photos):
                    // Fill collectionview
                    self.photoDataSource.photos = photos
                case let .Failure(error):
                    self.photoDataSource.photos.removeAll()
                }
                // update collectionview
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        // Before we get to the end of the collectionview, we want to start loading new photos
        let photo = photoDataSource.photos[indexPath.row]
        let lastPhoto = photoDataSource.photos.count - 25
        
        if indexPath.row == lastPhoto  {
            store.fetchRecentPhotos() {
                (photosResult) -> Void in
                // Use main thread
                OperationQueue.main.addOperation {
                    switch photosResult {
                    case let .Success(photos):
                        // Add photos to the existing collectionview
                        self.photoDataSource.photos.append(contentsOf: photos)
                    case let .Failure(error):
                        print(error)
                    }
                    // update collectionview
                    self.collectionView.reloadData()
                }
            }
        }
        
        // Fetch small size images
        store.fetchImageForPhoto(photo: photo, size: .Small) { (result) in
            // Use main thread
            OperationQueue.main.addOperation {
                let photoIndex = self.photoDataSource.photos.index(of: photo)!
                let photoIndexPath = IndexPath(item: photoIndex, section: 0)
                
                if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                    cell.updateWithImage(image: photo.image)
                }
            }
        }
    }
    
    // Go to full screen
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Index of photo we want to show full screen
        selectedPhotoIndex =  indexPath.row
        self.performSegue(withIdentifier: "ShowFullScreen", sender: self)
    }
    
    
    // Copy object to new viewcontroller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFullScreen" {
            if let destinationVC = segue.destination as? FullViewController {
                destinationVC.selectedPhotoIndex = self.selectedPhotoIndex
                destinationVC.photoDataSource = self.photoDataSource
                destinationVC.store = self.store
            }
        }
    }
}

