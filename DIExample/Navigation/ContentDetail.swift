//
//  ContentDetail.swift
//  DIExample
//
//  Created by Michael Link on 6/14/23.
//

import SwiftUI

@available(macOS 13.0, *)
struct ContentDetail: View {
    var content: Content?
    
    var body: some View {
        Group {
            if let content {
                content.destination
            } else {
                if #available(macOS 14.0, *) {
                    ContentUnavailableView("Select Something", systemImage: "list.bullet", description: Text("Pick something from the list."))
                } else {
                    Text("No Selection")
                }
            }
        }
        #if os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background()
        #endif
    }
}

@available(macOS 13.0, *)
struct ContentDetail_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetail()
    }
}
