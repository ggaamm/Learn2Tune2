//
//  WebClient.swift
//  Tourist
//
//  Created by gam on 5/18/20.
//  Copyright © 2020 gam. All rights reserved.
//

import Foundation
import UIKit

class HttpMethods {
    
    enum Method {
        case post, delete, put
    }
    
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, dataProcess: ((Data)->Data)?, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                print("getRequestToken decode")
                
                //MARK: skip 5 chars, required by Udacity
                if dataProcess != nil {
                    data = dataProcess!(data)
                }
                
                print(String(data: data, encoding: .utf8)!)
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ResponseType.self, from: data) as! Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
                
            }
        }
        task.resume()
        return task
    }
}
