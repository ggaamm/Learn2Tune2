//
//  Helper.swift
//  Tourist
//
//  Created by gam on 5/15/20.
//  Copyright © 2020 gam. All rights reserved.
//

import Foundation
import UIKit

/*
 https://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift
 */
extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}

extension UIButton {
    open override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.alpha = 1
            } else {
                self.alpha = 0.1
            }
        }
    }
}
