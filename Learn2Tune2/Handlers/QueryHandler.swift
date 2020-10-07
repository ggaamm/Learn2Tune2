//
//  QueryHandler.swift
//  Tourist
//
//  Created by gam on 5/21/20.
//  Copyright © 2020 gam. All rights reserved.
//

import Foundation
import CoreData


class QueryHandler: NSObject ,NSFetchedResultsControllerDelegate {
    
    var dataController: DataController!
    
    func deleteAllPins(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try dataController.viewContext.execute(batchDeleteRequest)
        } catch {
            print("Detele all data in \(Pin.self) error :", error)
        }
        
    }
    
    func printAllItems(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        guard let pins = fetchedResultsController.fetchedObjects as? [Pin] else {
            print("can't find the pin")
            return }
        for pin in pins {
            print(pin.latitude, pin.longitude)
        }
    }
}

