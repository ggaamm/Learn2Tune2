import Foundation
import UIKit

struct FlickrImageResult: Codable {
    let photos : FlickrPagedImageResult?
    let stat: String
}

struct FlickrPagedImageResult: Codable {
    let photo : [FlickrURL]
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
}

struct FlickrURL: Codable {
    let id : String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
}

struct FlickrImages {
    let images: [UIImage]
    let pages: Int
    let perpage: Int
    let total: Int
}

struct ImageLinks {
    var links: [String]
    var totalNoOfLinks:String
}

struct AzurePrediction: Codable {
    let created: Double?
    let predictedTagName: String?
    let prediction: Double?
}
