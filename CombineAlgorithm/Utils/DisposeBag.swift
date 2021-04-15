//
//  DisposeBag.swift
//  CombineAlgorithm
//
//  Created by admin on 15.04.2021.
//

import Foundation
import Combine

class  DisposeBag {

    private var storage = Set<AnyCancellable>()

    func addCancellable(_ cancellable: AnyCancellable) {
        storage.insert(cancellable)
    }

    func cancelAll() {
        storage.forEach {
            $0.cancel()
        }
        storage.removeAll()
    }
}

extension AnyCancellable {
    func store(in bag: DisposeBag) {
        bag.addCancellable(self)
    }
}
