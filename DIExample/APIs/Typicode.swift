//
//  Typicode.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import Foundation
import Combine
import os
import Factory

// very simple API to fetch some sample data

protocol Typicodable: Sendable {
    func posts() -> AnyPublisher<Result<[Typicode.Post], Error>, Never>
    func posts() async throws -> [Typicode.Post]

    func photos() -> AnyPublisher<Result<[Typicode.Photo], Error>, Never>
    func photos() async throws -> [Typicode.Photo]
}

final class Typicode: Typicodable {
    private let decoder = JSONDecoder()

    private func dataTaskPublisher<D>(for url: URL) -> AnyPublisher<Result<D, Error>, Never> where D : Decodable {
        return Self.urlSession
            .dataTaskPublisher(for: url)
            .tryMap({ data, response -> Data in
                guard !data.isEmpty else {
                    throw URLError(.zeroByteResource)
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }

                Logger().debug("✅ \(Thread.current) isMainThread=\(Thread.isMainThread) \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .binary)): \(url)")
                return data
            })
            .decode(type: D.self, decoder: decoder)
            .map { Result.success($0) }
            .catch { Just(Result.failure($0)) }
            .eraseToAnyPublisher()
    }

    private func data<D>(for url: URL) async throws -> D where D : Decodable {
        let (data, response) = try await Self.urlSession.data(from: url)

        guard !data.isEmpty else {
            throw URLError(.zeroByteResource)
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        Logger().debug("✅ \(Thread.current) isMainThread=\(Thread.isMainThread) \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .binary)): \(url)")
        return try decoder.decode(D.self, from: data)
    }

    private enum Endpoints {
        static let posts = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        static let photos = URL(string: "https://jsonplaceholder.typicode.com/photos")!
    }

    func posts() -> AnyPublisher<Result<[Post], Error>, Never> {
        return dataTaskPublisher(for: Endpoints.posts)
    }

    func posts() async throws -> [Typicode.Post] {
        return try await data(for: Endpoints.posts)
    }

    func photos() -> AnyPublisher<Result<[Photo], Error>, Never> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/photos")!

        return dataTaskPublisher(for: url)
    }

    func photos() async throws -> [Typicode.Photo] {
        return try await data(for: Endpoints.photos)
    }
}

extension Typicode {
    struct Post: Codable, Hashable, Identifiable {
        var id: UInt
        var userId: UInt
        var title: String
        var body: String
    }

    struct Photo: Codable, Hashable, Identifiable {
        var id: UInt
        var albumId: UInt
        var title: String
        var url: URL
    }
}

private extension Typicode {
    final class SessionDelegate: NSObject, URLSessionDelegate, Sendable {
        func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            let protectionSpace = challenge.protectionSpace

            guard protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }

            guard let serverTrust = protectionSpace.serverTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }

            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }

    static let urlSessionDelegate = SessionDelegate()
    static let urlSession = URLSession(configuration: .default, delegate: urlSessionDelegate, delegateQueue: nil)
}

extension Container {
    var typicode: Factory<Typicodable> {
        self { Typicode() }.shared
    }
}

#if DEBUG
extension Typicode.Post: PreviewProviderStub {
    static func previewProviderStub() -> Self {
        return .init(id: .random(in: 0..<UInt.max), userId: .random(in: 0..<UInt.max), title: String.randomString(count: .random(in: 32..<128)), body: String.randomString(count: .random(in: 64..<512)))
    }
}

extension Typicode.Photo: PreviewProviderStub {
    static func previewProviderStub() -> Self {
        return .init(id: .random(in: 0..<UInt.max), albumId: 0, title: String.randomString(count: .random(in: 32..<128)), url: URL(string: "https://picsum.photos/200")!)
    }
}
#endif
