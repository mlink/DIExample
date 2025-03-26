//
//  PostListViewModel14.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import Foundation
import Observation
import os
import Factory

@available(macOS 14.0, *)
@Observable @MainActor final class PostListViewModel14 {
    // by assigning directly via service locator we can maintain that `api` is a constant
    private let api = Container.shared.typicode()
    // using the property wrapper annotation style the api property must be a `var`
//    @Injected(\.typicode) private var api

    private(set) var posts = [Typicode.Post]()
    private(set) var filteredPosts = [Typicode.Post]()
    var searchText = ""
    private(set) var isLoading = false
    var showAlert = false
    private(set) var currentError: Error! = nil {
        didSet {
            guard currentError != nil else {
                return
            }

            showAlert = true
        }
    }
    private(set) var secondsSinceLastRefresh = 0
    @ObservationIgnored private var timerTask: TimerTask?

    deinit {
        timerTask?.cancel()
        print("☠️ \(Self.self) \(#function)")
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = .repeating(interval: .seconds(1), operation: { [weak self] in
            self?.secondsSinceLastRefresh += 1
        })
    }

    private func posts() async throws -> [Typicode.Post] {
        timerTask?.cancel()
        secondsSinceLastRefresh = 0
        isLoading = true
        defer {
            isLoading = false
            startTimer()
        }

        do {
            // uncomment to simulate a load delay
//            try? await Task.sleep(for: .seconds(1))
            // uncomment to simulate an error
//            throw CancellationError()
            return try await api.posts()
        } catch {
            currentError = error
            throw error
        }
    }

    func load() async {
        do {
            posts = try await posts()
            filterPosts()
        } catch {
            // if posts() throws then the user must manually refresh or handle the error
        }
    }
    
    private func filterPosts() {
        withObservationTracking {
            filteredPosts = posts.filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
        } onChange: { [weak self] in
            guard let self else { return }

            Task { @MainActor in
                self.filterPosts()
            }
        }
    }

    func refresh() {
        Task {
            posts = try await posts()
        }
    }
}
