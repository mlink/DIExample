//
//  XCTest+Additions.swift
//  DIExampleTests
//
//  Created by Michael Link on 7/26/22.
//

import XCTest

extension XCTestCase {
    /// Perform a structured concurrency assertion test. If `test` returns `false` then the test is rerun until it is `true` or a timeout occurs. Use this when you need to test the existence of something where the execution cannot be predicated such as when suspension points occur at `await` calls.
    func assert(description: String? = nil, timeout seconds: TimeInterval = 1.0, isInverted: Bool = false, _ test: @escaping () async -> Bool) async {
        let e = expectation(description: description ?? "\(Self.self)")

        e.isInverted = isInverted

        let detachedTask = Task<Void, Never>.detached(priority: .low) {
            while true {
                await Task.yield()

                do {
                    try Task.checkCancellation()
                } catch {
                    break
                }

                if await test() {
                    e.fulfill()
                    break
                }
            }
        }

        await fulfillment(of: [e], timeout: seconds)
        detachedTask.cancel()
        await detachedTask.value
    }

    func assert(description: String? = nil, timeout seconds: TimeInterval = 1.0, isInverted: Bool = false, _ test: @escaping () async throws -> Bool) async throws {
        let e = expectation(description: description ?? "\(Self.self)")

        e.isInverted = isInverted

        let detachedTask = Task<Void, Error>.detached(priority: .low) {
            while true {
                await Task.yield()

                do {
                    try Task.checkCancellation()
                } catch {
                    break
                }

                do {
                    if try await test() {
                        e.fulfill()
                        break
                    }
                } catch {
                    e.fulfill()
                    throw error
                }
            }
        }

        await fulfillment(of: [e], timeout: seconds)
        detachedTask.cancel()
        try await detachedTask.value
    }

    func wait(description: String? = nil, timeout seconds: TimeInterval = 1.0, isInverted: Bool = false, expectedFulfillmentCount: Int = 1, assertForOverFulfill: Bool = true, _ test: @escaping (XCTestExpectation) async -> Void) async {
        let e = expectation(description: description ?? "\(Self.self)")

        e.isInverted = isInverted
        e.expectedFulfillmentCount = expectedFulfillmentCount
        e.assertForOverFulfill = assertForOverFulfill

        let detachedTask = Task<Void, Never>.detached(priority: .low) {
            await Task.yield()

            do {
                try Task.checkCancellation()
            } catch {
                return
            }

            await test(e)
        }

        await fulfillment(of: [e], timeout: seconds)
        detachedTask.cancel()
        await detachedTask.value
    }

    func wait(description: String? = nil, timeout seconds: TimeInterval = 1.0, isInverted: Bool = false, expectedFulfillmentCount: Int = 1, assertForOverFulfill: Bool = true, _ test: @escaping (XCTestExpectation) async throws -> Void) async throws {
        let e = expectation(description: description ?? "\(Self.self)")

        e.isInverted = isInverted
        e.expectedFulfillmentCount = expectedFulfillmentCount
        e.assertForOverFulfill = assertForOverFulfill

        let detachedTask = Task<Void, Error>.detached(priority: .low) {
            await Task.yield()
            try Task.checkCancellation()
            try await test(e)
        }

        await fulfillment(of: [e], timeout: seconds)
        detachedTask.cancel()
        try await detachedTask.value
    }

    /// Creates an `XCTestExpectation` and then waits for it after executing the handler. The handler should call `fulfill()` on the expectation or some other test assertions to avoid waiting for timeout. Any exceptions are treated as failure.
    func wait(description: String? = nil, timeout seconds: TimeInterval = 1.0, isInverted: Bool = false, expectedFulfillmentCount: Int = 1, assertForOverFulfill: Bool = true, _ handler: (XCTestExpectation) throws -> Void) throws {
        let e = expectation(description: description ?? "\(Self.self)")

        e.isInverted = isInverted
        e.expectedFulfillmentCount = expectedFulfillmentCount
        e.assertForOverFulfill = assertForOverFulfill
        try wait(for: e, timeout: seconds, handler)
    }

    // TODO: consider other convenience init's

    /// Similar to the prior `wait` method except allows you to use any type of expectation.
    func wait(for expectation: XCTestExpectation, timeout seconds: TimeInterval = 1.0, _ handler: (XCTestExpectation) throws -> Void) throws {
        try handler(expectation)
        wait(for: [expectation], timeout: seconds)
    }
}
