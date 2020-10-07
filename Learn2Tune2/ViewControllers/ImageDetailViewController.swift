//
//  DetailViewController.swift
//  Learn2Tune
//
//  Created by gam on 6/9/20.
//  Copyright © 2020 gam. All rights reserved.
//

import UIKit
import CoreData



class ImageDetailViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<Label>!
    var photo: Photo!
    var dataController: DataController!
    var numberOfLabelsHandled = 0
    let textFieldDelegate = TextFieldDelegate()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var predictionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fetchPredictionsLabel: UILabel!
    @IBOutlet weak var enterLabelTextField: UITextField!
    @IBOutlet weak var userPredictionLabel: UILabel!
    @IBOutlet weak var activityIndicatorStackView: UIStackView!
 
    @IBAction func retryPrediction(_ sender: Any) {
        guard let url = photo.url else {
            return
        }
        activityIndicator.startAnimating()
        fetchPredictionsLabel.isHidden = false
        activityIndicatorStackView.isHidden = false
        enterLabelTextField.isEnabled = false
        AzureClient.getPredictionFromAzure(imageLoc: url, completion: AzurePredictionHandler(response:error:))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let photo = photo.photo{
            imageView.image = UIImage(data: photo)
            // Do any additional setup after loading the view.
            print("image loaded")
        }
        enterLabelTextField.delegate = textFieldDelegate
        addDoneButtonOnKeyboard()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // All notification unsubscriptions are here
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if self.view.frame.origin.y == 0  {
            if let activeField = textFieldDelegate.activeField {
                var aRect: CGRect = self.view.frame;
                aRect.size.height -= getKeyboardHeight(notification);
                
                // activefield is inside a stackview so convert it to global coordinates
                if !aRect.contains((activeField.superview?.convert(activeField.frame.origin, to: nil))!) {
                    self.view.frame.origin.y -= getKeyboardHeight(notification)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
        // keyboard hides when return is pressed so fetch the textfield value
        fetchLabels()
        if !fetchedResultsController.fetchedObjects!.isEmpty {
            let userInput = enterLabelTextField.text ?? ""
            fetchedResultsController.fetchedObjects?.first?.taggedLabel =  userInput
            if dataController.viewContext.hasChanges{
                try? dataController.viewContext.save()
                userPredictionLabel.text = "User Prediction: " + userInput
            }
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func fetchLabels() {
        let fetchRequest:NSFetchRequest<Label> = Label.fetchRequest()
        // Many to Many and Many To One have predicates
        //let predicateManyToOne = NSPredicate(format: "photo == %@", photo)
        let predicateManyToMany = NSPredicate(format: "ANY %K = %@", #keyPath(Label.toPhoto), photo)
        fetchRequest.predicate = predicateManyToMany
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(photo!)-labels")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func setupFetchedResultsController() {
        fetchLabels()
        fetchedResultsController.delegate = self
        
        numberOfLabelsHandled = fetchedResultsController.fetchedObjects!.count
        if numberOfLabelsHandled == 0 {
            guard let url = photo.url else {
                return
            }
            activityIndicator.startAnimating()
            fetchPredictionsLabel.isHidden = false
            activityIndicatorStackView.isHidden = false
            AzureClient.getPredictionFromAzure(imageLoc: url, completion: AzurePredictionHandler(response:error:))
        } else {
            for object in fetchedResultsController.fetchedObjects! {
                print("predicted label", object.predictedLabel ?? " ")
                var label = object.predictedLabel ?? ""
                predictionLabel.text = "Prediction: " + label
                label = object.taggedLabel ?? ""
                userPredictionLabel.text = "User Prediction " + label
            }
        }
    }
    
    func AzurePredictionHandler(response:
        AzurePrediction?, error: Error?)  {
        activityIndicator.stopAnimating()
        activityIndicatorStackView.isHidden = true
        fetchPredictionsLabel.isHidden = true
        enterLabelTextField.isEnabled = true
        
        guard let response = response else {
            showPredictionFailure(message: error?.localizedDescription ?? "Unknown prediction error!" )
            return
        }
        let label = Label(context: dataController.viewContext)
        if let date = response.created {
            let d =  Date(timeIntervalSince1970: date)
            label.creationDate = d
        } else {
            label.creationDate = Date()
        }
        
        let text = response.predictedTagName ?? ""
        label.predictedLabel = text
        photo.addToToLabels(label)
        predictionLabel.text = ""
        predictionLabel.text = "Prediction: " + label.predictedLabel!
        
        try? dataController.viewContext.save()
        print("Labels are fetched!")
    }
}

extension ImageDetailViewController{
    func showPredictionFailure(message: String) {
        let alertVC = UIAlertController(title: "Prediction Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // MARK: Use show or present depending on the current viewcontroller (in a navigation or not, tabbar etc.)
        present(alertVC, animated: true, completion: nil)
    }
    
    func addDoneButtonOnKeyboard()
    {
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        enterLabelTextField.inputAccessoryView = toolbar
    }
    
    @objc
    func doneButtonAction()
    {
        enterLabelTextField.resignFirstResponder()
    }
}
