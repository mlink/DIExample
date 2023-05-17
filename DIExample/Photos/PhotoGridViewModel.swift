//
//  PhotoGridViewModel.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import Foundation
import Combine
import Factory
import os

final class PhotoGridViewModel: ObservableObject {
    private let api = Container.shared.typicode()

    private let loadSubject = PassthroughSubject<Void, Never>()

    @Published private(set) var photos = [Typicode.Photo]()
    @Published private(set) var isLoading = false
    @Published var showAlert = false
    private(set) var currentError: Swift.Error! {
        didSet {
            guard currentError != nil else {
                return
            }

            showAlert = true
        }
    }
    private var cancellableSet = Set<AnyCancellable>()

    init() {
        loadSubject
            .handleEvents(receiveOutput: { [unowned self] in
                isLoading = true
            })
            .flatMap { [unowned self] in
                api.photos()
            }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] output in
                isLoading = false

                switch output {
                case let .success(value):
                    photos = value
                case let .failure(error):
                    currentError = error
                }
            }
            .store(in: &cancellableSet)
    }

    func load() {
        loadSubject.send()
    }

    func cancel() {
        cancellableSet.removeAll()
    }
}
