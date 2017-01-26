//
//  FullViewController.swift
//  FlickrApi
//
//  Created by Mark Aptroot on 24-01-17.
//  Copyright © 2017 Mark Aptroot. All rights reserved.
//



import UIKit


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
        
        collectionView.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        store.fetchImageForPhoto(photo: photo, size: .Big) { (result) in
            
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
        
        let indexPath = IndexPath(row: selectedPhotoIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left , animated: true)
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            let width = self.view.frame.size.width
            let height = self.view.frame.size.height
        
            return CGSize(width: width, height: height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
}
