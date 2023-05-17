//
//  PostListViewModelTests.swift
//  DIExampleTests
//
//  Created by Michael Link on 7/26/22.
//

import XCTest
import Combine
import AsyncAlgorithms
import Factory
@testable import DIExample

final class PostListViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Container.shared = Container()
    }

    func testViewModel() async throws {
        Container.shared.typicode.register { MockTypicode() }

        let viewModel = PostListViewModel()

        Task {
            await viewModel.load()
        }

        await wait { exception in
            for await posts in viewModel.$filteredPosts.values {
                if posts == [Typicode.Post].stub(count: 1) {
                    break
                }
            }

            exception.fulfill()
        }
    }

    func testSearchResults() async throws {
        Container.shared.typicode.register { MockTypicode() }

        let viewModel = PostListViewModel()

        Task {
            await viewModel.load()
        }
        Task { @MainActor in
            viewModel.searchText = "title"
        }

        await wait { exception in
            for await posts in viewModel.$filteredPosts.values {
                if posts == [Typicode.Post].stub(count: 1), await viewModel.searchText == "title" {
                    break
                }
            }

            exception.fulfill()
        }
    }

    func testSearchResultsEmpty() async throws {
        Container.shared.typicode.register { MockTypicode() }

        let viewModel = PostListViewModel()

        Task {
            await viewModel.load()
        }
        Task { @MainActor in
            viewModel.searchText = "foo"
        }

        await wait { exception in
            for await posts in viewModel.$filteredPosts.values {
                if posts.isEmpty, await viewModel.searchText == "foo" {
                    break
                }
            }

            exception.fulfill()
        }
    }

    func testViewModelError() async throws {
        class MockTypicodeError: MockTypicode {
            enum MockError: Error {
                case mockError
            }

            override func posts() async throws -> [Typicode.Post] {
                throw MockError.mockError
            }
        }

        Container.shared.typicode.register { MockTypicodeError() }

        let viewModel = PostListViewModel()

        Task {
            await viewModel.load()
        }

        await assert {
            guard await viewModel.showAlert == true, let error = await viewModel.currentError, case MockTypicodeError.MockError.mockError = error else {
                return false
            }

            return true
        }
    }
}
