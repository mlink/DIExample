//
//  ContentSidebarList.swift
//  DIExample
//
//  Created by Michael Link on 6/14/23.
//

import SwiftUI

@available(macOS 13.0, *)
struct ContentSidebarList: View {
    @Binding var selection: Content?
    
    var body: some View {
        List(Content.allCases, selection: $selection) { content in
            NavigationLink(value: content) {
                content.label
            }
        }
        .navigationTitle("Dependency Injection Example")
    }
}

@available(macOS 13.0, *)
struct ContentSidebarList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationSplitView {
            if #available(macOS 14.0, *) {
                ContentSidebarList(selection: .constant(.posts14))
            } else {
                ContentSidebarList(selection: .constant(.posts))
            }
        } detail: {
            Text(verbatim: "Check out that sidebar!")
        }
    }
}
