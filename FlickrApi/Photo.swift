//
//  Photo.swift
//  FlickrApi
//
//  Created by Mark Aptroot on 23-01-17.
//  Copyright © 2017 Mark Aptroot. All rights reserved.
//

import UIKit


class Photo {
    let title: String
    let remoteURLSmall: NSURL
    let remoteURLBig: NSURL
    let photoID: String
    let dateTaken: Date
    var size: PhotoSize?
    var image: UIImage?
    
    
    init(title: String, photoID: String, remoteURLSmall: NSURL, remoteURLBig: NSURL, dateTaken: Date) {
        self.title = title
        self.photoID = photoID
        self.remoteURLSmall = remoteURLSmall
        self.remoteURLBig = remoteURLBig
        self.dateTaken = dateTaken
    }
}


extension Photo: Equatable{}

func == (lhs: Photo, rhs: Photo) -> Bool {
    return lhs.photoID == rhs.photoID
}
