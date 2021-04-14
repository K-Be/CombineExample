//
//  ViewController.swift
//  CombineAlgorithm
//
//  Created by admin on 12.04.2021.
//

import UIKit

class ViewController: UIViewController, BackendDelegate, InputControllerDelegate {
    let backend = Backend()
    let inputController = InputController()
    let networkTasks = WeakStorage<BackendTaskStub>()

    @IBOutlet var startChangeButton: UIButton!
    @IBOutlet var sendPasswordButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var passwordTextInput: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var publicKey: String = ""

    enum State {
        case start
        case waitInput
        case sending
    }
    var state: State = .start {
        didSet {
            self.startChangeButton.isEnabled = (self.state == .start)
            self.sendPasswordButton.isEnabled = (self.state == .sending)
            self.passwordTextInput.isEnabled = (self.state == .waitInput)
            self.cancelButton.isEnabled = (self.state == .sending || self.state == .waitInput)
            if self.state == .waitInput {
                self.passwordTextInput.becomeFirstResponder()
            }
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.state = .start
        // Do any additional setup after loading the view.
        self.backend.delegate = self
        self.inputController.textField = self.passwordTextInput
        self.inputController.delegate = self
        self.sendPasswordButton.addTarget(self, action: #selector(sendAction(_:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        self.startChangeButton.addTarget(self, action: #selector(startChangeAction(_:)), for: .touchUpInside)
    }

    private func configure() {
        self.backend.delegate = self
    }

    private func displayActivity(_ display: Bool) {
        if display {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }

    private func loadPublicKey() {
        self.displayActivity(true)
        let task = self.backend.retrievePublicKey()
        self.networkTasks.addObject(task)
    }

    private func sendNewPassword() {
        self.displayActivity(true)
        self.state = .sending
        let task = self.backend.retrievePasswordChanging(withPassword: self.passwordTextInput.text ?? "", publicKey: self.publicKey)
        self.networkTasks.addObject(task)
    }

    // MARK: BackendDelegate
    func backendLoadedPublicKey(_ key: String) {
        self.publicKey = key
        self.displayActivity(false)
        self.state = .waitInput
    }

    func backendChangedPassword() {
        self.publicKey = ""
        self.displayActivity(false)
        self.state = .start
    }

    // MARK: InputControllerDelegate
    func inputController(_ sender: InputController, didInputText text: String) {
        self.state = .sending
    }

    // MARK: Actions
    @objc func startChangeAction(_ sender: Any?) {
        self.loadPublicKey()
    }

    @objc func cancelAction(_ sender: Any?) {
        self.networkTasks.forEach { (task:BackendTaskStub) in
            task.cancel()
        }
        self.networkTasks.removeAll()
        self.state = .start
        self.displayActivity(false)
    }

    @objc func sendAction(_ sender: Any?) {
        self.sendNewPassword()
    }
}

