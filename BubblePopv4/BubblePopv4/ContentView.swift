//
//  ContentView.swift
//  BubblePopv4
//
//  Created by JohnTSS on 10/4/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showNameAlert = false
    @State private var playerName = ""
    @State private var gameIsActive = false
    
    @EnvironmentObject var gameSettings: GameSettings
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Bubble Pop")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                Button("Play") {
                    // Reset gameIsActive in case it was previously set
                    gameIsActive = false
                    // Show the alert to enter the name
                    showNameAlert = true
                }
                .alert("Enter Your Name", isPresented: $showNameAlert) {
                    TextField("Name", text: $playerName)
                        .foregroundColor(.black)
                    Button("OK") {
                        let trimmedName = playerName.trimmingCharacters(in: .whitespaces)
                        if !trimmedName.isEmpty {
                            gameIsActive = true
                            gameSettings.playerName = trimmedName // Ensure you have a playerName property in GameSettings
                            gameSettings.startGame()
                            playerName = ""
                        } else {
                            // Optionally, provide feedback that name is required
                            showNameAlert = true // Reactivate alert if name is empty
                        }
                    }
                } message: {
                    Text("Please enter your name to start.")
                }
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 240, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                
                NavigationLink(destination: PlayView(), isActive: $gameIsActive) {
                    EmptyView() // Hidden Navigation Link
                }
                
                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 240, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
                
                NavigationLink(destination: HighScoreBoardView()) {
                    Text("High Score Board")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 240, height: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(GameSettings())
}
