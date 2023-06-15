//
//  PostListViewModel14.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import Foundation
import Observation
import Factory
import os

@available(macOS 14.0, *)
@Observable final class PostListViewModel14 {
    // by assigning directly via service locator we can maintain that `api` is a constant
    private let api = Container.shared.typicode()
    // using the property wrapper annotation style the api property must be a `var`
//    @Injected(\.typicode) private var api

    @MainActor private(set) var posts = [Typicode.Post]()
    @MainActor private(set) var filteredPosts = [Typicode.Post]()
    @MainActor var searchText = ""
    @MainActor private(set) var isLoading = false
    @MainActor var showAlert = false
    @MainActor private(set) var currentError: Error! = nil {
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
            try? await Task.sleep(for: .seconds(1))
            // uncomment to simulate an error
//            throw CancellationError()
            return try await api.posts()
        } catch {
            currentError = error
            throw error
        }
    }

    @MainActor func load() async {
        do {
            posts = try await posts()
            filterPosts()
        } catch {
            // if posts() throws then the user must manually refresh or handle the error
        }
    }
    
    @MainActor private func filterPosts() {
        withObservationTracking {
            filteredPosts = posts.filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
        } onChange: {
            Task { @MainActor in
                self.filterPosts()
            }
        }
    }

    func refresh() {
        Task { @MainActor in
            posts = try await posts()
        }
    }
}
