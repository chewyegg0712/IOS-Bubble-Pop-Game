//
//  SettingsView.swift
//  BubblePopv4
//
//  Created by JohnTSS on 10/4/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameSettings: GameSettings
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Game Time: \(Int(gameSettings.gameTime)) seconds")
                    .font(.title2)
                Slider(value: $gameSettings.gameTime, in: 1...60, step: 1)
                    .padding(.horizontal)
                
                Text("Number of Bubbles: \(Int(gameSettings.maxBubbles))")
                    .font(.title2)
                Slider(value: $gameSettings.maxBubbles, in: 1...15, step: 1)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameSettings())
}
