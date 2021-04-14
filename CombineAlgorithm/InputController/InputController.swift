//
//  InputController.swift
//  CombineAlgorithm
//
//  Created by admin on 13.04.2021.
//

import Foundation
import UIKit


protocol InputControllerDelegate: AnyObject {
    func inputController(_ sender: InputController, didInputText text: String)
}

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
    weak var delegate: InputControllerDelegate?

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField?.resignFirstResponder()
        self.delegate?.inputController(self, didInputText: textField.text ?? "")
        return true
    }

}
