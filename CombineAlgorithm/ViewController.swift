//
//  ViewController.swift
//  CombineAlgorithm
//
//  Created by admin on 12.04.2021.
//

import UIKit
import Combine

class ViewController: UIViewController {
    let backend = Backend()
    let inputController = InputController()
    let networkTasks = WeakStorage<BackendTaskStub>()

    @IBOutlet var startChangeButton: UIButton!
    var startButtonListener = ControlCombineListener()
    @IBOutlet var sendPasswordButton: UIButton!
    var sendPasswordButtonListener = ControlCombineListener()
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var passwordTextInput: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var disposeBag = DisposeBag()

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

            if self.state == .start {
                self.disposeBag.cancelAll()
                self.passwordTextInput.text = ""
                self.buildAlgorithm()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.inputController.textField = self.passwordTextInput
        self.sendPasswordButtonListener.listenButton(self.sendPasswordButton)
        self.cancelButton.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        self.startButtonListener.listenButton(self.startChangeButton)
        self.state = .start
    }

    private func buildAlgorithm() {
        let bag = self.disposeBag
        self.startButtonListener.publisher.sink { [weak self] ( ) in
            self?.loadPublicKey().sink { (key:String) in
                self?.loadedPublicKey(key)
                let future = self?.waitInputPassword()
                future?.sink { (_) in
                    self?.state = .sending
                    self?.sendPasswordButtonListener.publisher.sink { () in
                        self?.sendNewPassword().sink { () in
                            self?.didSendPassword()
                        }.store(in: bag)
                    }.store(in: bag)
                }.store(in: bag)
            }.store(in: bag)
        }.store(in: bag)
    }

    private func displayActivity(_ display: Bool) {
        if display {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }

    private func loadPublicKey() -> Future<String, Never> {
        self.displayActivity(true)
        let task = self.backend.retrievePublicKey()
        return task
    }

    private func sendNewPassword() -> Future<Void, Never> {
        self.displayActivity(true)
        self.state = .sending
        let task = self.backend.retrievePasswordChanging(withPassword: self.passwordTextInput.text ?? "", publicKey: self.publicKey)
        return task
    }

    fileprivate func loadedPublicKey(_ key: String) {
        self.publicKey = key
        self.displayActivity(false)
        self.state = .waitInput
    }

    fileprivate func didSendPassword() {
        self.publicKey = ""
        self.displayActivity(false)
        self.state = .start
    }

    private func waitInputPassword() -> Future<String, Never> {
        let bag = self.disposeBag
        let future = Future<String, Never> { [weak self](promise) in
            self?.inputController.publisher.sink { (value) in
                promise(.success(value))
            }.store(in: bag)
        }
        return future
    }

    // MARK: Actions
    @objc func cancelAction(_ sender: Any?) {
        self.networkTasks.forEach { (task:BackendTaskStub) in
            task.cancel()
        }
        self.networkTasks.removeAll()
        self.state = .start
        self.displayActivity(false)
    }
}

