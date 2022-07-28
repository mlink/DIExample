//
//  PostDetailView.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import SwiftUI

struct PostDetailView: View {
    private let post: Typicode.Post

    init(post: Typicode.Post) {
        self.post = post
    }

    var body: some View {
        ScrollView {
            Text(post.body)
                .font(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding()
        }
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(post: Typicode.Post(id: 0, userId: 0, title: "Title", body: "Lorem ipsum doler…"))
    }
}
