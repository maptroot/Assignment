//
//  PhotoStore.swift
//  FlickrApi
//
//  Created by Mark Aptroot on 23-01-17.
//  Copyright © 2017 Mark Aptroot. All rights reserved.
//

import UIKit


enum ImageResult {
    case Success(UIImage)
    case Failure(Error)
}

enum PhotoError: Error {
    case ImageCreationErrror
}

enum PhotoSize {
    case Small
    case Big
}

class PhotoStore {

    var page: Int = 0
    
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // Request photos from Flickr
    func fetchRecentPhotos(completion: @escaping (PhotosResult) -> Void) {
        
        
        // To prevent getting the same batch of photos over and over, we wil ask Flickr for the next page
        self.page += 1
        let url  = FlickrAPI.recentPhotosURL(page: page)
        
        let request = URLRequest(url: url as URL)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            
            let result = self.processRecentPhotosRequest(data: data, error: error)
            completion(result)
        })
        task.resume()
    }
    
    // Check if we got data
    func processRecentPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsondData = data else {
            return .Failure(error!)
        }
        
        return FlickrAPI.photosFromJSONData(data: jsondData)
    }
    
    
    // Get the image for a photo
    func fetchImageForPhoto(photo: Photo, size: PhotoSize, completion: @escaping (ImageResult) -> Void) {
        
        
        // Check if we want a different size image if we already have an image
        let photoSize = size
        
        if let image = photo.image {
            if photo.size == photoSize {
                // We already have image of the correct size
                completion(.Success(image))
                return
            }
        }
        
        
        // Get URL for requierd size
        var photoURL: URL
        
        switch size {
        case .Small:
            photoURL = photo.remoteURLSmall as URL
        case .Big:
            photoURL = photo.remoteURLBig as URL
        }
        
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .Success(image) = result {
                // Set image and size of photo
                photo.image = image
                photo.size = photoSize
            }
            completion(result)
        }
        task.resume()
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                if data == nil {
                    return .Failure(error!)
                } else {
                    return .Failure(PhotoError.ImageCreationErrror)
                }
        }
        
        return .Success(image)
    }
    
    
}
