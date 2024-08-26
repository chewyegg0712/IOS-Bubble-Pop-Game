//
//  BubblePopv4App.swift
//  BubblePopv4
//
//  Created by JohnTSS on 10/4/2024.
//

import SwiftUI

@main
 struct BubblePopv4App: App {
    var gameSettings = GameSettings()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameSettings)
        }
    }
}
