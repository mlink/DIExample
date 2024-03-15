//
//  PhotoGridViewModelTests.swift
//  DIExampleTests
//
//  Created by Michael Link on 7/27/22.
//

@preconcurrency import XCTest
import Combine
@preconcurrency import Factory
@testable import DIExample

final class PhotoGridViewModelTests: XCTestCase {
    var cancellableSet = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        cancellableSet.removeAll()
        Container.shared.reset()
    }

    func testViewModel() throws {
        Container.shared.typicode.register { MockTypicode() }

        let viewModel = PhotoGridViewModel()
        let expectation = expectation(description: "\(#function)")
        
        viewModel.$photos.sink { output in
            if output == [Typicode.Photo].stub(count: 1) {
                expectation.fulfill()
            }
        }.store(in: &cancellableSet)

        viewModel.load()
        wait(for: [expectation])
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

        Container.shared.typicode.register { MockTypicodeError() }

        let viewModel = PhotoGridViewModel()
        let expectation = expectation(description: "\(#function)")
       
        
        viewModel.$showAlert.sink { output in
            if output, let error = viewModel.currentError, case MockTypicodeError.MockError.mockError = error {
                expectation.fulfill()
            }
        }.store(in: &cancellableSet)

        viewModel.load()
        wait(for: [expectation])
    }
}
