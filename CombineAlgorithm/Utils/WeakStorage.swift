//
//  WeakStorage.swift
//  CombineAlgorithm
//
//  Created by admin on 14.04.2021.
//

import Foundation

class WeakStorage <Type: AnyObject> {
    private var storage = Array<WeakContainer<Type> >()

    func addObject(_ object: Type) {
        storage.append(WeakContainer(value: object))
    }

    func removeObject(_ obj: Type) {
        storage.removeAll { (container: WeakContainer<Type>) -> Bool in
            let remove = (container.value === obj)
            return remove
        }
    }

    func forEach(_ block: (_ object: Type)->Void) {
        let nonNilList = storage.filter { (container:WeakContainer<Type>) -> Bool in
            return container.value != nil
        }
        nonNilList.forEach { (container:WeakContainer<Type>) in
            if let value = container.value {
                block(value)
            }
        }
        self.storage = nonNilList
    }

    func removeAll() {
        self.storage.removeAll()
    }
}
