//
//  Stub.swift
//  DIExample
//
//  Created by Michael Link on 7/26/22.
//

import Foundation

protocol Stub {
    static func stub() -> Self
}

extension Stub {
    /// Set writable `var` property.
    func set<Value>(_ keyPath: WritableKeyPath<Self, Value>, to value: Value) -> Self {
        var stub = self
        stub[keyPath: keyPath] = value
        return stub
    }

    /// Set constant `let` property.
    ///  - SeeAlso: [MemoryLayout.swift](https://github.com/apple/swift/blob/dfb01b6a6af454bc90fae4ee3026936104661f13/stdlib/public/core/MemoryLayout.swift#L160-L229)
    func set<Value>(_ keyPath: KeyPath<Self, Value>, to value: Value) -> Self {
        guard let offset = MemoryLayout<Self>.offset(of: keyPath) else {
            fatalError("\(keyPath) is not writable. Properties are not directly accessible if they trigger any `didSet` or `willSet` accessors, perform any representation changes such as bridging or closure reabstraction, or mask the value out of overlapping storage as for packed bitfields. In addition, because class instance properties are always stored out-of-line, their positions are not accessible")
        }

        var stub = self

        withUnsafeMutableBytes(of: &stub) { bytes in
            let rawPointerToValue = bytes.baseAddress! + offset
            let pointerToValue = rawPointerToValue.assumingMemoryBound(to: Value.self)
            pointerToValue.pointee = value
        }

        return stub
    }
}

extension Array where Element: Stub {
    static func stub(element: @autoclosure () -> Element = .stub(), count: Int) -> Self {
        (0..<count).map { _ in element() }
    }
}

extension MutableCollection where Element: Stub {
    func set<Value>(_ keyPath: WritableKeyPath<Element, Value>, to value: @autoclosure () -> Value) -> Self {
        var collection = self

        for index in collection.indices {
            let element = collection[index]
            collection[index] = element.set(keyPath, to: value())
        }

        return collection
    }

    func set<Value>(_ keyPath: KeyPath<Element, Value>, to value: @autoclosure () -> Value) -> Self {
        var collection = self

        for index in collection.indices {
            let element = collection[index]
            collection[index] = element.set(keyPath, to: value())
        }

        return collection
    }
}
