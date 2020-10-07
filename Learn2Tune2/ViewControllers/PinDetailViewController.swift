//
//  PinDetailViewController.swift
//  Learn2Tune
//
//  Created by gam on 6/9/20.
//  Copyright © 2020 gam. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class PinDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    weak var mh: MapHandler!
    var pin: Pin!
    var dataController:DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var numberOfCells: Int = Constant.noOfImagesToDownload
    let reuseIdentifier = "photoCVCell"
    @IBOutlet weak var noPhotosLabel: UILabel!
    var numberOfImagesHandled:Int = 0
    let hapticNotification = UINotificationFeedbackGenerator()

    
    @IBAction func newCollectionButton(_ sender: UIButton) {

        if let objects = fetchedResultsController.fetchedObjects {
            for object in objects {
                dataController.viewContext.delete(object)
                downloadImagesFromCurrentPinLocation(perPage: 1, completion: downloadLinksHandler)
                try?        dataController.viewContext.save()
            }
        }
    }
    
    func fetchPhotos() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func setupFetchedResultsController() {
        fetchPhotos()
        fetchedResultsController.delegate = self
        
        numberOfImagesHandled = fetchedResultsController.fetchedObjects!.count
        if numberOfImagesHandled < numberOfCells || numberOfImagesHandled == 0  {
            downloadImagesFromCurrentPinLocation(perPage: 1, completion: downloadLinksHandler )
        }
        
        newCollectionButton.adjustsImageWhenDisabled = true
        newCollectionButton.isEnabled =  self.pin.total > Int64(numberOfCells) ? true : false
        print("Isbutton enabled: \(newCollectionButton.isEnabled) ")
    }
    
    func downloadLinksHandler() {
        if numberOfImagesHandled > numberOfCells - 1  {
            return
        } else {
            downloadImagesFromCurrentPinLocation(perPage: 1, completion: downloadLinksHandler)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        numberOfImagesHandled = fetchedResultsController.fetchedObjects!.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.backBarButtonItem?.title = "OK";
        
        let coordinate = CLLocationCoordinate2D(latitude: mh.coordDict["mapLat"]!,
                                                longitude: mh.coordDict["mapLong"]!)
        mh.addAnnotation(to: mapView, at: coordinate)
        mapView.setCenter(coordinate, animated: false)
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        initCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        setupFetchedResultsController()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: Download Images
    func downloadImagesFromCurrentPinLocation(perPage: Int, completion: @escaping () -> Void) {
        newCollectionButton.isEnabled = false
        collectionView.allowsSelection = false
        var noOfPages = max(pin.total, 0)
        noOfPages = min(noOfPages, Int64(Constant.FlickrMaxPageLimit))
        print(noOfPages)
        let page = Int.random(in:0...Int(noOfPages))
        let imageLocation = FlickrImageLocation(lat: String(pin.latitude), long: String(pin.longitude), radius: "10", page: String(page), perpage:  String(perPage))
        
        FlickrClient.getImageLinks(imageLoc: imageLocation) { [weak self] (flickrImageLinks, error) in
            guard let weakSelf = self else { return }
            guard let imageLinks = flickrImageLinks  else {
                print("flickr failed")
                weakSelf.noPhotosLabel.isHidden = false
                weakSelf.noPhotosLabel.text = "Error: Accessing photos!"
                return
            }
            weakSelf.pin.total = Int64(imageLinks.totalNoOfLinks)!
            for link in imageLinks.links {
                let photo = Photo(context: weakSelf.dataController.viewContext)
                photo.creationDate = Date()
                photo.pin = weakSelf.pin
                photo.url = link
                
                weakSelf.dataController.viewContext.insert(photo)
                print("download print after insert")
                
                do {
                    try weakSelf.dataController.viewContext.save()
                } catch {
                    print("downloadLinks context save failed")
                }
            }
            weakSelf.collectionView.allowsSelection = true
            if weakSelf.pin.total < 1 {
                weakSelf.noPhotosLabel.isHidden = false
            }
            
            if weakSelf.pin.total >= Constant.noOfImagesToDownload {
                weakSelf.newCollectionButton.isEnabled = true
            }
            weakSelf.numberOfCells = min(Int(weakSelf.pin.total), weakSelf.numberOfCells)
            weakSelf.numberOfImagesHandled += 1
            completion()
        }
    }
}

// MARK: CV Delegates
extension PinDetailViewController {
    
    // MARK: FlowLayout
    func initCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        
        let space: CGFloat = 3.0
        let val = UIScreen.main.bounds.width
        let dimension = (val - (2 * space)) / 3.5 // 3.08 for ipad
        let hdimension = (val - (2 * space)) / 3.5 // 3.08 for ipad
        
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: hdimension)
        flowLayout.headerReferenceSize = CGSize(width: 0, height: 4)
        flowLayout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        collectionView.collectionViewLayout = flowLayout
        noPhotosLabel.isHidden = true
        
        let deleteCellLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        deleteCellLongGesture.minimumPressDuration = 1.0
        deleteCellLongGesture.delegate = self
        deleteCellLongGesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(deleteCellLongGesture)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let val = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return val
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PinDetailCollectionViewCell
        cell.activityIndicator.startAnimating()
        cell.pinPhotoImageView.image = #imageLiteral(resourceName: "placeholder")
        print("inside cell: count ",fetchedResultsController.fetchedObjects!.count)
        if fetchedResultsController.fetchedObjects!.isEmpty {
            return cell
        }
        
        let photoObject = fetchedResultsController.object(at: indexPath)
        if let photo = photoObject.photo {
            cell.pinPhotoImageView.image = UIImage(data: photo)
            cell.activityIndicator.stopAnimating()
        } else {
            FlickrClient.getImages(imageLocation: photoObject.url!, completion: { (data) in
                if let data = data {
                    cell.pinPhotoImageView.image = UIImage(data: data)
                    photoObject.photo = data
                }
                cell.activityIndicator.stopAnimating()
            })
        }
        return cell
    }
    
}

extension PinDetailViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            hapticNotification.notificationOccurred(.success)
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        default:
            print("Unknown operation on the managed object context")
        }
    }
    
    // MARK: Short Press to jump to detail view
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            collectionView.insertSections(indexSet)
        case .delete:
            collectionView.insertSections(indexSet)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        default:
            print("unknown")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("collection did selectItemAt")
        print("show detail view and check label")
        print("indexPath", indexPath)
        let photo = fetchedResultsController.object(at: indexPath)
        // send photo to prepare for segue method
        performSegue(withIdentifier: "detailViewSegue", sender: photo)
        hapticNotification.notificationOccurred(.success)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailViewSegue" {
            let photo = sender as? Photo
            print("photo: ", photo ?? "no photo")
            
            let vc = segue.destination as! ImageDetailViewController
            vc.dataController = dataController
            vc.photo = photo
            
        }
    }
}

// MARK: Long press to delete the photo
extension PinDetailViewController {
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.collectionView)
        
        if let indexPath = self.collectionView.indexPathForItem(at: p) {
            print("indexPath: ", indexPath)
            let photo = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(photo)
            do {
                try dataController.viewContext.save()
                
            } catch {
                print("Item delete view context save failed")
            }
        } else {
            print("couldn't find index path")
        }
    }
}

