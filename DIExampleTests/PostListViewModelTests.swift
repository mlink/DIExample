//
//  PostListViewModelTests.swift
//  DIExampleTests
//
//  Created by Michael Link on 7/26/22.
//

@preconcurrency import XCTest
import Combine
import AsyncAlgorithms
@preconcurrency import Factory
@testable import DIExample

final class PostListViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        Container.shared.reset()
    }

    @MainActor func testViewModel() async throws {
        Container.shared.typicode.register { MockTypicode() }

        let viewModel = PostListViewModel()

        Task {
            await viewModel.load()
        }

        let expectation = expectation(description: "\(#function)")
        
        Task {
            for await posts in viewModel.$filteredPosts.values {
                if posts == [Typicode.Post].stub(count: 1) {
                    expectation.fulfill()
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation])
    }

    @MainActor func testSearchResults() async throws {
        Container.shared.typicode.register { MockTypicode() }

        let viewModel = PostListViewModel()

        Task {
            await viewModel.load()
        }
        Task {
            viewModel.searchText = "title"
        }
        
        let expectation = expectation(description: "\(#function)")

        Task {
            for await posts in viewModel.$filteredPosts.values {
                if posts == [Typicode.Post].stub(count: 1), viewModel.searchText == "title" {
                    expectation.fulfill()
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation])
    }

    @MainActor func testSearchResultsEmpty() async throws {
        Container.shared.typicode.register { MockTypicode() }

        let viewModel = PostListViewModel()

        Task {
            await viewModel.load()
        }
        Task {
            viewModel.searchText = "foo"
        }
        
        let expectation = expectation(description: "\(#function)")

        Task {
            for await posts in viewModel.$filteredPosts.values {
                if posts.isEmpty, viewModel.searchText == "foo" {
                    expectation.fulfill()
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation])
    }

    @MainActor func testViewModelError() async throws {
        class MockTypicodeError: MockTypicode, @unchecked Sendable {
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
        
        let expectation = expectation(description: "\(#function)")

        Task {
            for await showAlert in viewModel.$showAlert.values where showAlert == true {
                if let error = viewModel.currentError, case MockTypicodeError.MockError.mockError = error {
                    expectation.fulfill()
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation])
    }
}
