//
//  AsyncChannel+Void.swift
//  DIExample
//
//  Created by Michael Link on 7/27/22.
//

import AsyncAlgorithms

extension AsyncChannel where Element == Void {
    func send() async {
        await send(())
    }
}
