//
//  Content.swift
//  DIExample
//
//  Created by Michael Link on 6/14/23.
//

import SwiftUI

enum Content: Identifiable, Hashable, CaseIterable {
    @available(macOS 14.0, *)
    case posts14
    case posts
    case photos
    
    var id: Self {
        self
    }
    
    static var allCases: [Self] {
        if #available(macOS 14.0, *) {
            [.posts14, .posts, .photos]
        } else {
            [.posts, .photos]
        }
    }
}

extension Content {
    @ViewBuilder var label: some View {
        switch self {
        case .posts14: Label("Posts14", systemImage: "mail.stack")
        case .posts: Label("Posts", systemImage: "mail.stack")
        case .photos: Label("Photos", systemImage: "photo.on.rectangle.angled")
        }
    }
    
    @ViewBuilder var destination: some View {
        switch self {
        case .posts14:
            if #available(macOS 14.0, *) {
                PostListView14()
            } else {
                Text("Content only available on MacOS 14 or higher.")
            }
        case .posts: PostListView()
        case .photos: PhotoGridView()
        }
    }
}
