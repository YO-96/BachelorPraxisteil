//
//  IndexCardsApp.swift
//  IndexCards
//
//  Created by Yannick Opp on 05.04.22.
//

import SwiftUI

@main
struct IndexCardsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(IndexCardSetModel())
        }
    }
}

