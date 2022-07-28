//
//  Stub.swift
//  DIExample
//
//  Created by Michael Link on 7/26/22.
//

import Foundation

#if DEBUG
// This is nearly identical to `Stub` in the test target, but we need to differentiate the names to avoid collisions. We could import `Stub` to the app target but then having it wrapped in `#if DEBUG` could cause problems for certain build schemes and we want to keep this under DEBUG because preview code doesn't belong in production code.
protocol PreviewProviderStub {
    static func previewProviderStub() -> Self
}

extension PreviewProviderStub {
    /// Set writable `var` property.
    func assign<Value>(_ keyPath: WritableKeyPath<Self, Value>, to value: Value) -> Self {
        var stub = self
        stub[keyPath: keyPath] = value
        return stub
    }

    /// Set constant `let` property.
    ///  - SeeAlso: [MemoryLayout.swift](https://github.com/apple/swift/blob/dfb01b6a6af454bc90fae4ee3026936104661f13/stdlib/public/core/MemoryLayout.swift#L160-L229)
    func assign<Value>(_ keyPath: KeyPath<Self, Value>, to value: Value) -> Self {
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

extension Array where Element: PreviewProviderStub {
    static func previewProviderStub(element: @autoclosure () -> Element = .previewProviderStub(), count: Int) -> Self {
        (0..<count).map { _ in element() }
    }
}

extension MutableCollection where Element: PreviewProviderStub {
    func assign<Value>(_ keyPath: WritableKeyPath<Element, Value>, to value: @autoclosure () -> Value) -> Self {
        var collection = self

        for index in collection.indices {
            let element = collection[index]
            collection[index] = element.assign(keyPath, to: value())
        }

        return collection
    }

    func set<Value>(_ keyPath: KeyPath<Element, Value>, to value: @autoclosure () -> Value) -> Self {
        var collection = self

        for index in collection.indices {
            let element = collection[index]
            collection[index] = element.assign(keyPath, to: value())
        }

        return collection
    }
}

extension String {
    /// Convenience to generate a random string.
    static func randomString(count: Int = 32) -> Self {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 "
        return String((0..<count).map { _ in characters.randomElement()! })
    }
}
#endif
