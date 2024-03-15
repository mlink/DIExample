//
//  Typicode+Mock.swift
//  DIExampleTests
//
//  Created by Michael Link on 7/27/22.
//

import Foundation
import Combine
@testable import DIExample

extension Typicode.Post: Stub {
    static func stub() -> Self {
        return .init(id: 0, userId: 0, title: "title", body: "body")
    }
}

extension Typicode.Photo: Stub {
    static func stub() -> Self {
        return .init(id: 0, albumId: 0, title: "title", url: URL(string: "https://picsum.photos/200")!)
    }
}

// `@unchecked Sendable` is fine for testing
class MockTypicode: Typicodable, @unchecked Sendable {
    func posts() -> AnyPublisher<Result<[Typicode.Post], Error>, Never> {
        return Just(Result.success([Typicode.Post].stub(count: 1)))
            .eraseToAnyPublisher()
    }

    func posts() async throws -> [Typicode.Post] {
        return [Typicode.Post].stub(count: 1)
    }

    func photos() -> AnyPublisher<Result<[Typicode.Photo], Error>, Never> {
        return Just(Result.success([Typicode.Photo].stub(count: 1)))
            .eraseToAnyPublisher()
    }

    func photos() async throws -> [Typicode.Photo] {
        [Typicode.Photo].stub(count: 1)
    }
}
