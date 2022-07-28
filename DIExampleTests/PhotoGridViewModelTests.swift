//
//  PhotoGridViewModelTests.swift
//  DIExampleTests
//
//  Created by Michael Link on 7/27/22.
//

import XCTest
import Combine
import Factory
@testable import DIExample

final class PhotoGridViewModelTests: XCTestCase {
    var cancellableSet = Set<AnyCancellable>()

    override func setUpWithError() throws {
        Container.Registrations.push()
    }

    override func tearDownWithError() throws {
        Container.Registrations.pop()
        cancellableSet.removeAll()
    }

    func testViewModel() throws {
        Container.typicode.register { MockTypicode() }

        let viewModel = PhotoGridViewModel()
        
        try wait { expectation in
            viewModel.$photos.sink { output in
                if output == [Typicode.Photo].stub(count: 1) {
                    expectation.fulfill()
                }
            }.store(in: &cancellableSet)

            viewModel.load()
        }
    }

    func testViewModelError() throws {
        class MockTypicodeError: MockTypicode {
            enum MockError: Error {
                case mockError
            }

            override func photos() -> AnyPublisher<Result<[Typicode.Photo], Error>, Never> {
                return Just(Result.failure(MockTypicodeError.MockError.mockError))
                    .eraseToAnyPublisher()
            }
        }

        Container.typicode.register { MockTypicodeError() }

        let viewModel = PhotoGridViewModel()

        try wait { expectation in
            viewModel.$showAlert.sink { output in
                if output, let error = viewModel.currentError, case MockTypicodeError.MockError.mockError = error {
                    expectation.fulfill()
                }
            }.store(in: &cancellableSet)

            viewModel.load()
        }
    }
}
