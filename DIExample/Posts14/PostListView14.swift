//
//  PostListView14.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import SwiftUI

@available(macOS 14.0, *)
struct PostListView14: View {
    @Bindable private var viewModel = PostListViewModel14()
    @State private var selection: Typicode.Post?

    var body: some View {
        NavigationSplitView {
            PostList(posts: viewModel.filteredPosts, selection: $selection, searchText: $viewModel.searchText)
        } detail: {
            if viewModel.isLoading {
                ContentUnavailableView {
                    ProgressView("Loading…")
                }
            } else if viewModel.posts.isEmpty {
                ContentUnavailableView("Data Unavailable", systemImage: "network.slash")
            } else if !viewModel.searchText.isEmpty, viewModel.filteredPosts.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            } else if let selection {
                PostDetailView(post: selection)
                    #if os(macOS)
                    .background()
                    #endif
            } else {
                ContentUnavailableView("Select a Post", systemImage: "mail")
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("Try Again") {
                viewModel.refresh()
            }
            Button("Cancel", role: .cancel, action: {})
        }
        .navigationTitle("Posts14")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Text("\(viewModel.secondsSinceLastRefresh)")
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .task {
            if viewModel.filteredPosts.isEmpty {
                await viewModel.load()
            }
        }
    }
}

#if DEBUG
import Combine
import Factory

@available(macOS 14.0, *)
struct PostListView14_Previews: PreviewProvider {
    private final class MockTypicode: Typicodable {
        func posts() -> AnyPublisher<Result<[Typicode.Post], Error>, Never> {
            return Just(Result.success([Typicode.Post].previewProviderStub(count: 32)))
                .eraseToAnyPublisher()
        }

        func posts() async throws -> [Typicode.Post] {
            return [Typicode.Post].previewProviderStub(count: 32)
        }

        func photos() -> AnyPublisher<Result<[Typicode.Photo], Error>, Never> {
            return Just(Result.success([Typicode.Photo].previewProviderStub(count: 32)))
                .eraseToAnyPublisher()
        }

        func photos() async throws -> [Typicode.Photo] {
            [Typicode.Photo].previewProviderStub(count: 32)
        }
    }

    static var previews: some View {
        let _ = Container.shared.typicode.register { MockTypicode() }

        PostListView14()
    }
}
#endif
