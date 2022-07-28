//
//  PhotoGridView.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import SwiftUI

struct PhotoGridView: View {
    @EnvironmentObject private var viewModel: PhotoGridViewModel

    var body: some View {
        ZStack {
            Text("")
                .alert(isPresented: $viewModel.showAlert, content: {
                    Alert(title: Text("Error"), message: Text(viewModel.currentError.localizedDescription), primaryButton: .default(Text("Try Again"), action: {
                        viewModel.load()
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
            } else if viewModel.photos.isEmpty {
                VStack {
                    Spacer()
                    Button("Load") {
                        viewModel.load()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .center, spacing: 4, content: {
                        ForEach(viewModel.photos) { photo in
                            AsyncImage(url: photo.url) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "photo")
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 80, height: 80)
                        }
                    })
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Photos")
        .toolbar {
            Button {
                viewModel.load()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(viewModel.isLoading)
        }
        .onAppear {
            viewModel.load()
        }
    }
}

struct PhotoGridView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoGridView()
    }
}
