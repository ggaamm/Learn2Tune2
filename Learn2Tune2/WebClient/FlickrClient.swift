//
//  FlickrClient.swift
//  Learn2Tune
//
//  Created by gam on 6/10/20.
//  Copyright © 2020 gam. All rights reserved.
//

import Foundation

import Foundation
import UIKit



class FlickrClient {
    
    struct Auth {
        static var apiKey = "API KEY HERE"
    }
    
    enum Endpoints {
        static let flickrBase = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Auth.apiKey)&lat={lat}&lon={long}&radius={radius}&per_page={perpage}&page={page}&format=json&nojsoncallback=1"
        static let imageBase = "https://farm{farmId}.staticflickr.com/{serverId}/{id}_{secret}_z.jpg"
        
        case getImageLinks(FlickrImageLocation)
        case getImage(FlickrURL)
        
        var stringValue: String {
            switch self {
            case .getImageLinks(let flickrImageLocs):
                let link = Endpoints.flickrBase.replacingOccurrences(of: "{lat}", with: flickrImageLocs.lat).replacingOccurrences(of: "{long}", with: flickrImageLocs.long).replacingOccurrences(of: "{radius}", with: flickrImageLocs.radius).replacingOccurrences(of: "{perpage}", with: flickrImageLocs.perpage).replacingOccurrences(of: "{page}", with: flickrImageLocs.page)
                return link
            case .getImage(let flickrUrl):
                let link = Endpoints.imageBase.replacingOccurrences(of: "{farmId}", with: "\(flickrUrl.farm)").replacingOccurrences(of: "{serverId}", with: flickrUrl.server).replacingOccurrences(of: "{id}", with: flickrUrl.id).replacingOccurrences(of: "{secret}", with: flickrUrl.secret)
                return link
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func handleDataProcess(data: Data) -> Data {
        let range = 5..<data.count
        return data.subdata(in: range)
    }
    
    class func getImages(imageLocation: String, completion: @escaping (Data?) -> Void)  {
        let url = URL(string: imageLocation)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data)
            }
        }
        task.resume()
    }
    
    class func getImageLinks(imageLoc: FlickrImageLocation, completion: @escaping (ImageLinks?, Error?) -> Void) {
        //print("linksurl \(Endpoints.getImageLinks(imageLoc).url)")
        let url = Endpoints.getImageLinks(imageLoc).url
        print("get Image Links url: \(url)")
        HttpMethods.taskForGETRequest(url: url, response: FlickrImageResult.self, dataProcess: nil) { (response, error) in
            guard let response = response, let links = response.photos  else {
                completion(nil, error)
                return
            }
            
            if response.stat != "ok" {return completion(nil, error)}
            
            var imageLinks = ImageLinks(links: [String](), totalNoOfLinks: response.photos!.total)
            for link in links.photo {
                let imageLink = Endpoints.getImage(link).stringValue
                imageLinks.links.append(imageLink)
            }
            completion(imageLinks, nil)
        }
    }
}
