//
//  Requests.swift
//  Tourist
//
//  Created by gam on 5/31/20.
//  Copyright © 2020 gam. All rights reserved.
//

import Foundation


struct FlickrImageLocation {
    var lat: String
    var long: String
    var radius: String
    var page: String
    var perpage: String = String(Constant.noOfImagesToDownload)
}
