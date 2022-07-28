//
//  ContentView.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: PostListView()) {
                    Label("Posts", systemImage: "mail.stack")
                }
                NavigationLink(destination: PhotoGridView()) {
                    Label("Photos", systemImage: "photo.on.rectangle.angled")
                }
            }
            .listStyle(.sidebar)

            Text("Select a Category")
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
        }
    }

    private func toggleSidebar() {
        #if os(iOS)
        #else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
