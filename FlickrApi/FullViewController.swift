//
//  FullViewController.swift
//  FlickrApi
//
//  Created by Mark Aptroot on 24-01-17.
//  Copyright © 2017 Mark Aptroot. All rights reserved.
//



import UIKit


// shows full screen horizontal swiping images
class FullViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var store: PhotoStore!
    var selectedPhotoIndex: Int!
    var photoDataSource: PhotoDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // After collectionview has moved to the selected image we can unhide it
        collectionView.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        
        // Get a full size image
        store.fetchImageForPhoto(photo: photo, size: .Big) { (result) in
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        // Move the collectionview to the selected image. Because of the centerd paging we must use animated while collectionview is hidden
        let indexPath = IndexPath(row: selectedPhotoIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left , animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Make the collectionview full screen
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        return CGSize(width: width, height: height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Smooth paging effect
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
}
