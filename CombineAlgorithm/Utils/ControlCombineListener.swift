//
//  ControlCombineListener.swift
//  CombineAlgorithm
//
//  Created by admin on 14.04.2021.
//

import Foundation
import UIKit
import Combine

class ControlCombineListener {
    let publisher = PassthroughSubject<Void, Never>()

    func listenButton(_ button: UIControl) {
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }

    @objc private func buttonAction(_ sender: Any?) {
        self.publisher.send()
    }
}

