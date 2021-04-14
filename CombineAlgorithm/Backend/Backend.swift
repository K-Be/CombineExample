//
//  Backend.swift
//  CombineAlgorithm
//
//  Created by admin on 12.04.2021.
//

import Foundation

protocol Cancellable: AnyObject {
    func cancel()
}

protocol BackendDelegate: AnyObject {
    func backendLoadedPublicKey(_ key: String)
    func backendChangedPassword()
}

class Backend {
    weak var delegate: BackendDelegate?

    func retrievePublicKey() -> BackendTaskStub {
        let task = BackendTaskStub(withTime: 2.0) {
            self.delegate?.backendLoadedPublicKey("Secret");
        }
        task.resume()
        return task
    }

    func retrievePasswordChanging(withPassword password:String, publicKey: String) -> BackendTaskStub {
        let task = BackendTaskStub(withTime: 2.0) {
            self.delegate?.backendChangedPassword()
        }
        task.resume()
        return task
    }
}


