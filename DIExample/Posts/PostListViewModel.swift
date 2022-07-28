//
//  PostListViewModel.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import Foundation
import Combine
import AsyncAlgorithms
import os
import Factory

final class PostListViewModel: ObservableObject {
    // by assigning directly via service locator we can maintain that `api` is a constant
    private let api = Container.typicode()
    // using the property wrapper annotation style the api property must be a `var`
//    @Injected(Container.typicode) private let api

    // similar to a `PassthroughSubject`
    private let loadChannel = AsyncChannel<Void>()
    private var cachedPosts = [Typicode.Post]()

    @MainActor @Published private(set) var filteredPosts = [Typicode.Post]()
    @MainActor @Published var searchText = ""
    @MainActor @Published private(set) var isLoading = false
    @MainActor @Published var showAlert = false
    @MainActor private(set) var currentError: Error! {
        didSet {
            guard currentError != nil else {
                return
            }

            showAlert = true
        }
    }

    @MainActor private func posts() async throws -> [Typicode.Post] {
        isLoading = true
        defer { isLoading = false }

        do {
            return try await api.posts()
        } catch {
            currentError = error
            throw error
        }
    }

    @MainActor func load() async {
        let searchTextStream = $searchText
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .values
        let postsStream = AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let task = Task {
                if !cachedPosts.isEmpty {
                    continuation.yield(cachedPosts)
                }

                for await _ in loadChannel {
                    do {
                        cachedPosts = try await posts()
                        continuation.yield(cachedPosts)
                    }
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
                Logger().debug("\(#function):\(#line): ☠️ posts stream canceled")
            }
        }

        // load initial data
        if cachedPosts.isEmpty {
            await loadChannel.send()
        }

        // this needs to be setup each time since this task is canceled when the view disappears, which is convenient, no more `cancellables` to deal with
        for await (posts, searchText) in combineLatest(postsStream, searchTextStream) {
            filteredPosts = posts
                .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
            Logger().debug("\(#function):\(#line): posts=\(posts.count) filteredPosts=\(self.filteredPosts.count) search=\"\(searchText)\"")
        }
    }

    func refresh() {
        Task {
            await loadChannel.send()
        }
    }
}