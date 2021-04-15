//
//  Backend.swift
//  CombineAlgorithm
//
//  Created by admin on 12.04.2021.
//

import Foundation
import Combine

protocol Cancellable: AnyObject {
    func cancel()
}

class Backend {
    func retrievePublicKey() -> Future<String, Never> {
        return Future { promise in
            let task = BackendTaskStub(withTime: 2.0) {
                promise(.success("Secret"))
            }
            task.resume()
        }
    }

    func retrievePasswordChanging(withPassword password:String, publicKey: String) -> Future<Void, Never> {
        return Future { promise in
            let task = BackendTaskStub(withTime: 2.0) {
                promise(.success( () ))
            }
            task.resume()
        }
    }
}


