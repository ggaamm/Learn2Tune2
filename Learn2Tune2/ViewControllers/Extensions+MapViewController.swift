//
//  Extensions+MapViewController.swift
//  Tourist
//
//  Created by gam on 5/14/20.
//  Copyright © 2020 gam. All rights reserved.
//

import Foundation
import UIKit
import MapKit


extension MapViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pinDetailSegue" {
            let vc = segue.destination as! PinDetailViewController
            vc.mh = mapHandler
            vc.dataController = dataController
            vc.pin = pin
        }
    }
    
    @objc func handleMapViewLongPress(gestureRecogniser: UIGestureRecognizer) {
        if gestureRecogniser.state == .ended {
            print("there is tap")
            let location = gestureRecogniser.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let lat = coordinate.latitude//.round(to: 3)
            let long = coordinate.longitude//.round(to: 3)
            // create a pin and add to the database
            pin = Pin(context: dataController.viewContext)
            pin.creationDate = Date()
            pin.latitude = lat
            pin.longitude = long
            if dataController.viewContext.hasChanges {
                try? dataController.viewContext.save()
            }
            mapHandler.coordDict["mapLat"] = lat
            mapHandler.coordDict["mapLong"] = long
            mapHandler.addAnnotation(to: mapView, at: coordinate)
            print("context saved")
            performSegue(withIdentifier: "pinDetailSegue", sender: nil)
            mapView.setCenter(coordinate, animated: false)
        }
    }
}
