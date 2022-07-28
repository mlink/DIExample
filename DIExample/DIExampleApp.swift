//
//  DIExampleApp.swift
//  DIExample
//
//  Created by Michael Link on 7/20/22.
//

import SwiftUI

@main
struct DIExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PostListViewModel())
                .environmentObject(PhotoGridViewModel())
        }
    }
}
