//
//  InputController.swift
//  CombineAlgorithm
//
//  Created by admin on 13.04.2021.
//

import Foundation
import UIKit
import Combine

class InputController: NSObject, UITextFieldDelegate {
    var textField: UITextField? {
        willSet {
            if self.textField?.delegate === self {
                self.textField?.delegate = nil
            }
        }
        didSet {
            self.textField?.delegate = self
        }
    }
    let publisher = PassthroughSubject<String, Never>()

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField?.resignFirstResponder()
        self.publisher.send(textField.text ?? "")
        return true
    }

}
