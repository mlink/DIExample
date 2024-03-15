//
//  ContentView.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Content?
    
    var body: some View {
        if #available(macOS 13.0, *) {
            NavigationSplitView {
                ContentSidebarList(selection: $selection)
            } detail: {
                ContentDetail(content: selection)
            }
        } else {
            NavigationView {
                // the List must be inline here otherwise the sidebar will be disabled
                List(Content.allCases) { content in
                    NavigationLink(destination: content.destination) {
                        content.label
                    }
                }
                .listStyle(.sidebar)
                .navigationTitle("Dependency Injection Example")
                
                Text("No Selection")
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.leading")
                    })
                }
            }
        }
    }

    @MainActor private func toggleSidebar() {
        #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PostListViewModel())
            .environmentObject(PhotoGridViewModel())
    }
}
