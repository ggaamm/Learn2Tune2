//
//  TextFieldHandler.swift
//  Learn2Tune
//
//  Created by gam on 6/13/20.
//  Copyright © 2020 gam. All rights reserved.
//
import Foundation
import UIKit

// MARK: - TextFieldDeledate: NSObject, UITextFieldDelegate

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    var activeField: UITextField?
    let hapticNotification = UINotificationFeedbackGenerator()

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hapticNotification.notificationOccurred(.success)
        textField.resignFirstResponder()
        return true;
    }
    

}
