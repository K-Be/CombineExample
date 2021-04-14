//
//  BackendTaskStub.swift
//  CombineAlgorithm
//
//  Created by admin on 12.04.2021.
//

import Foundation

class BackendTaskStub : Cancellable {
    let time: TimeInterval
    let block: () -> Void
    private weak var timer: Timer?

    init(withTime time: TimeInterval, block: @escaping () -> Void) {
        self.time = time
        self.block = block
    }

    func resume() {
        let timer = Timer(timeInterval: self.time,
                          repeats: false) { (_) in
            self.block()
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func cancel() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

