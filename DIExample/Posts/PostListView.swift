//
//  PostListView.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import SwiftUI

struct PostListView: View {
    // an alternative to `@EnvironmentObject` is to use `@StateObject` which would recreate the view model each time the view is created
//    @StateObject private var viewModel = PostListViewModel()
    @EnvironmentObject private var viewModel: PostListViewModel
    @State private var selection: Typicode.Post?

    var body: some View {
        if #available(macOS 13.0, *) {
            NavigationSplitView {
                PostList(posts: viewModel.filteredPosts, selection: $selection, searchText: $viewModel.searchText)
            } detail: {
                if viewModel.isLoading {
                    ProgressView("Loading…")
                } else if viewModel.cachedPosts.isEmpty {
                    Text("Data Unavailable")
                } else if !viewModel.searchText.isEmpty, viewModel.filteredPosts.isEmpty {
                    Text("No Results")
                } else if let selection {
                    PostDetailView(post: selection)
                        #if os(macOS)
                        .background()
                        #endif
                } else {
                    Text("No Selection")
                }
            }
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("Try Again") {
                    viewModel.refresh()
                }
                Button("Cancel", role: .cancel, action: {})
            }
            .navigationTitle("Posts")
            .toolbar {
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
                    // this will never return and will continue to await on the `AsyncStream`, it will be canceled when the view disappears
                    await viewModel.load()
                }
            }
        } else {
            ZStack {
                Text("")
                    .alert(isPresented: $viewModel.showAlert, content: {
                        Alert(title: Text("Error"), message: Text(viewModel.currentError.localizedDescription), primaryButton: .default(Text("Try Again"), action: {
                            viewModel.refresh()
                        }), secondaryButton: .cancel())
                    })
                
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        Text("Loading…")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    NavigationView {
                        List {
                            ForEach(viewModel.filteredPosts) { post in
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    Text(post.title)
                                }
                            }
                        }
                        .listStyle(.bordered(alternatesRowBackgrounds: true))
                        .searchable(text: $viewModel.searchText)
                        
                        Text("No selection")
                    }
                }
            }
            .navigationTitle("Posts")
            .toolbar {
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
                    // this will never return and will continue to await on the `AsyncStream`, it will be canceled when the view disappears
                    await viewModel.load()
                }
            }
        }
    }
}

#if DEBUG
import Combine
import Factory

struct PostListView_Previews: PreviewProvider {
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

        PostListView()
            .environmentObject(PostListViewModel())
    }
}
#endif
