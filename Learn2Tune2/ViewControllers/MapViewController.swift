//
//  MapViewController.swift
//  Learn2Tune
//
//  Created by gam on 6/9/20.
//  Copyright © 2020 gam. All rights reserved.
//

//
//  ViewController.swift
//  Tourist
//
//  Created by gam on 5/14/20.
//  Copyright © 2020 gam. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    let mapHandler = MapHandler()
    var imageLinks = [UIImage]()
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    var dataController: DataController!
    let queryHandler = QueryHandler()
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapHandler.mapViewController = self
        initMapView()
        queryHandler.dataController = dataController
        setupFetchedResultsController()
    }
    
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        guard let pins = fetchedResultsController.fetchedObjects else { return }
        for pin in pins {
            let loc = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            mapHandler.addAnnotation(to: mapView, at: loc)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func initMapView() {
        mapView.delegate = mapHandler
        let mapviewGestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(handleMapViewLongPress(gestureRecogniser:)))
        mapviewGestureRecognizer.minimumPressDuration = 1.0
        mapviewGestureRecognizer.delegate = self
        mapView.addGestureRecognizer(mapviewGestureRecognizer)
        let coords = UserDefaults.standard.object(forKey: "coordDict") as? [String: Double] ?? mapHandler.coordDict
        let location = CLLocationCoordinate2D(latitude: coords["mapLat"]!, longitude: coords["mapLong"]!)
        let span = MKCoordinateSpan(latitudeDelta: coords["latDelta"]!, longitudeDelta: coords["longDelta"]!)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        mapView.isScrollEnabled = true
        mapHandler.dataController = dataController
    }
}
