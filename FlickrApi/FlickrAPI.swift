//
//  FlickrAPI.swift
//  FlickrApi
//
//  Created by Mark Aptroot on 23-01-17.
//  Copyright © 2017 Mark Aptroot. All rights reserved.
//

import Foundation

enum Method: String {
    
    case RecentPhotos = "flickr.photos.getRecent"
    //case RecentPhotos = "flickr.interestingness.getList"
}

enum PhotosResult {
    case Success([Photo])
    case Failure(Error)
    
}

enum FlickrError: Error {
    case InvalidJSONData
}


struct FlickrAPI {
    
    fileprivate static let baseURLString = "https://api.flickr.com/services/rest"
    fileprivate static let APIKey = "a6d819499131071f158fd740860a5a88"
    
    
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    fileprivate static func photoFromJSONObject(json: [String: Any]) -> Photo? {
        guard let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLStringSmall = json["url_s"] as? String,
            let photoURLStringBig = json["url_h"] as? String,
            let urlSmall = NSURL(string: photoURLStringSmall),
            let urlBig = NSURL(string: photoURLStringBig),
            let dateTaken = dateFormatter.date(from: dateString) else {

                return nil
        }
        
        return Photo(title: title, photoID: photoID, remoteURLSmall: urlSmall, remoteURLBig: urlBig, dateTaken: dateTaken)
    }
    
    fileprivate static func flickrURL(method: Method, parameters: [String:String]?) -> NSURL {
        
        let components = NSURLComponents(string: baseURLString)!
        
        var queryItems = [NSURLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": APIKey
        ]
        
        for (key,value) in baseParams {
            let item = NSURLQueryItem(name: key, value: value)
            queryItems.append(item)
            
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = NSURLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
            
        }
        
        components.queryItems = queryItems as [URLQueryItem]?
        
        return components.url! as NSURL
    }
    
    
    static func recentPhotosURL(page: Int) -> NSURL {
        
        return flickrURL(method: .RecentPhotos, parameters: ["per_page": "60", "page": String(page), "extras": "url_s,url_h,date_taken"])
    }
    
    
    static func photosFromJSONData(data: Data) -> PhotosResult {
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data as Data, options: [])
            
            guard let jsonDictionary = jsonObject as? [AnyHashable: Any],
                let photos = jsonDictionary["photos"] as? [String: Any],
                let photosArray = photos["photo"] as?  [[String:Any]]
                else {
                    return .Failure(FlickrError.InvalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            for photoJSON in photosArray {
                if let photo = photoFromJSONObject(json: photoJSON) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.isEmpty && !photosArray.isEmpty {
                return .Failure(FlickrError.InvalidJSONData)
                
            }
            return .Success(finalPhotos)
        }
        catch let error {
            return .Failure(error)
        }
        
    }
    
    
}


