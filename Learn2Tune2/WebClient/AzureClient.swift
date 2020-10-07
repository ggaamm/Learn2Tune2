//
//  AzureClient.swift
//  Learn2Tune
//
//  Created by gam on 6/10/20.
//  Copyright © 2020 gam. All rights reserved.
//

import Foundation
import UIKit



class AzureClient {
    
    struct Auth {
        static var apiKey = "API KEY HERE"
    }
    
    enum Endpoints {
        static let azureBase = "https://*****.azurewebsites.net/api/"
       
        case getPrediction(String)
        
        var stringValue: String {
            switch self {
            case .getPrediction(let imageLink):
                let link = Endpoints.azureBase + "ImCl?img=" + imageLink
                return link
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getPredictionFromAzure(imageLoc: String, completion: @escaping (AzurePrediction?, Error?) -> Void) {
        //print("linksurl \(Endpoints.getImageLinks(imageLoc).url)")
        let url = Endpoints.getPrediction(imageLoc).url
        print("get Image Links url: \(url)")
        HttpMethods.taskForGETRequest(url: url, response: AzurePrediction.self, dataProcess: nil) { (response, error) in
            guard let response = response  else {
                completion(nil, error)
                return
            }
            completion(response, nil)
        }
    }
}
