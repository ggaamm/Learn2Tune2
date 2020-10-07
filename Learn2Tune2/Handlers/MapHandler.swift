//
//  MapHandler.swift
//  Tourist
//
//  Created by gam on 5/14/20.
//  Copyright © 2020 gam. All rights reserved.
//
import UIKit
import Foundation
import MapKit
import CoreData

class MapHandler: NSObject, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    //default coordinates
    var coordDict:[String:Double] = Constant.defaultLocation
    weak var mapViewController: MapViewController!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    let qh = QueryHandler()

    
    func addAnnotation(to mapView: MKMapView!, at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Coord: \(annotation.coordinate.latitude.round(to: 2)), \(annotation.coordinate.longitude.round(to: 2)) "
        var annotations = mapView.annotations
        annotations.append(annotation)
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    func saveMapLocation(_ mapView: MKMapView, coordinate:CLLocationCoordinate2D?) {
        coordDict["mapLat"] = coordinate != nil ? coordinate?.latitude : mapView.region.center.latitude//.round(to: 3)
        coordDict["mapLong"] = coordinate != nil ? coordinate?.longitude : mapView.region.center.longitude//.round(to: 3)
        coordDict["latDelta"] = mapView.region.span.latitudeDelta//.round(to: 3)
        coordDict["longDelta"] = mapView.region.span.longitudeDelta//.round(to: 3)
        
        UserDefaults.standard.set(coordDict, forKey: "coordDict")
    }
    
    // Save map location after region is changed
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("region has changed")
        saveMapLocation(mapView, coordinate: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            print("rightCalloutAccessoryView is pushed")
            // go to detailview
            let lat = view.annotation!.coordinate.latitude//.round(to: 2)
            let long = view.annotation!.coordinate.longitude//.round(to: 2)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            print("lat", lat, "long", long)
            let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", NSNumber(floatLiteral: lat), NSNumber(floatLiteral: long))
            fetchRequest.predicate = predicate
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            let
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("The fetch could not be performed: \(error.localizedDescription)")
            }
            guard let pins = fetchedResultsController.fetchedObjects as? [Pin] else {
                print("can't find the pin")
                return }
            if pins.count >= 1 {
            mapViewController.pin = pins[0]
            mapViewController.performSegue(withIdentifier: "pinDetailSegue", sender: nil)
            } else {
                print("pins count is, ", pins.count)
                qh.dataController = dataController
                //qh.printAllPins()
            }
        } else if control == view.leftCalloutAccessoryView {
            print("leftCalloutAccessoryView is pushed")
            
        } else if control == view.detailCalloutAccessoryView {
            print("detailCalloutAccessoryView is pushed")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let pins = fetchedResultsController.fetchedObjects else {
            print("can't find the pin")
            return }
        mapViewController.pin = pins[0]
        mapViewController.performSegue(withIdentifier: "pinDetailSegue", sender: nil)
    }
}
