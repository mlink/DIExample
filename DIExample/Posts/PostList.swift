//
//  PostList.swift
//  DIExample
//
//  Created by Michael Link on 6/14/23.
//

import SwiftUI

@available(macOS 13.0, *)
struct PostList: View {
    let posts: [Typicode.Post]
    @Binding private(set) var selection: Typicode.Post?
    @Binding private(set) var searchText: String
    
    var body: some View {
        List(posts, selection: $selection) { post in
            NavigationLink(value: post) {
                Text(post.title)
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
        .searchable(text: $searchText)
    }
}

#if DEBUG
@available(macOS 13.0, *)
struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationSplitView {
            PostList(posts: [Typicode.Post].previewProviderStub(count: 32), selection: .constant(nil), searchText: .constant(""))
        } detail: {
            Text(verbatim: "Check out that sidebar!")
        }
    }
}
#endif
