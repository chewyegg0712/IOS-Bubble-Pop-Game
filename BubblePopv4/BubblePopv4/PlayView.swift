//
//  PlayView.swift
//  BubblePopv4
//
//  Created by JohnTSS on 10/4/2024.
//

import SwiftUI

struct PlayView: View {
    @EnvironmentObject var gameSettings: GameSettings
    @State private var bubblePositions: [CGPoint] = []
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>  // To control navigation stack
    @State private var showHighScores = false  // State to control navigation to the High Scores View
    @State private var moveTimer: Timer?
    @State private var isFirstAppear = true // State to track if the view appears for the first time
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if gameSettings.showCountdown{
                    countdownView
                }
                else if gameSettings.gameOver {
                    gameOverView
                } else {
                    gameActiveView(geometry: geometry)
                }
            }
        }
        .onChange(of: gameSettings.timeLeft) { _ in
            if gameSettings.timeLeft <= 0 {
                gameSettings.endGame()
            }
        }
        .onAppear {
            if isFirstAppear {
                gameSettings.startCountdown()
                startMoveTimer()
                isFirstAppear = false // Set to false after first initialization
            }
        }
        .onDisappear(){
            moveTimer?.invalidate()
        }
        .navigationTitle("Bubble Pop Game")
        .navigationBarHidden(gameSettings.gameOver)
    }
    
    var countdownView: some View {
        ZStack {
            Color.black.opacity(0.75).edgesIgnoringSafeArea(.all)
            Text(gameSettings.countdown > 0 ? "\(gameSettings.countdown)" : "Start!")
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(gameSettings.countdown > 0 ? 1 : 1.5)
                .animation(.easeInOut, value: gameSettings.countdown)
        }
    }
    
    func gameActiveView(geometry: GeometryProxy) -> some View {
        VStack {
            statusView
            Spacer()
            bubbleDisplayArea(geometry: geometry)
        }
        .onAppear {
            placeBubbles(in: geometry.size)
        }
        .onReceive(gameSettings.$bubbles) { _ in
            placeBubbles(in: geometry.size)
        }
    }
    
    var gameOverView: some View {
        VStack {
            Spacer()
            Text("Game Over")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.red)
            Text("Final Score: \(gameSettings.currentScore)")
                .font(.title2)
                .padding(.top, 5)
            Spacer()
            Button("Restart Game") {
                gameSettings.startCountdown()
                gameSettings.startGame()
                startMoveTimer()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 20)
            
            Button("View High Scores") {
                showHighScores = true
            }
            .buttonStyle(.bordered)
            .padding(.bottom, 10)
            
            NavigationLink(destination: HighScoreBoardView(), isActive: $showHighScores) {
                EmptyView()
            }
            
            Button("Return to Main Menu") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.bordered)
            .padding(.bottom, 20)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
    
    var statusView: some View {
        HStack {
            Text("Time Left: \(gameSettings.timeLeft) sec")
            Spacer()
            Text("Score: \(gameSettings.currentScore)")
            Spacer()
            Text("High Score: \(gameSettings.highestScore)")
        }
        .padding()
        .font(.headline)
    }
    
    private func bubbleDisplayArea(geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(gameSettings.bubbles.indices, id: \.self) { index in
                if index < bubblePositions.count {
                    BubbleView(bubble: gameSettings.bubbles[index], position: bubblePositions[index]) {
                        if !gameSettings.gameOver {
                            gameSettings.popBubble(bubble: gameSettings.bubbles[index])
                        }
                    }
                }
            }
        }
    }
    
    private func placeBubbles(in size: CGSize) {
        bubblePositions = gameSettings.calculateNonOverlappingPositions(count: gameSettings.bubbles.count, in: size)
    }
    
    private func startMoveTimer() {
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            moveBubbles()
        }
    }
    
    private func moveBubbles() {
        guard gameSettings.bubbles.count == bubblePositions.count else {
            return  // Re-sync positions or handle error
        }
        
        for index in gameSettings.bubbles.indices {
            var newPosition = bubblePositions[index]
            let movementX = gameSettings.bubbles[index].speed * gameSettings.bubbles[index].direction.x
            let movementY = gameSettings.bubbles[index].speed * gameSettings.bubbles[index].direction.y
            
            // Calculate new position based on current movement
            newPosition.x += movementX
            newPosition.y += movementY
            
            // Reflect bubble if it hits the horizontal boundaries
            if newPosition.x < GameSettings.bubbleRadius || newPosition.x > UIScreen.main.bounds.width - GameSettings.bubbleRadius {
                gameSettings.bubbles[index].direction.x *= -1
                newPosition.x = max(GameSettings.bubbleRadius, min(newPosition.x, UIScreen.main.bounds.width - GameSettings.bubbleRadius))
            }
            
            // Reflect bubble if it hits the vertical boundaries
            if newPosition.y < GameSettings.bubbleRadius || newPosition.y > UIScreen.main.bounds.height - GameSettings.bubbleRadius {
                gameSettings.bubbles[index].direction.y *= -1
                newPosition.y = max(GameSettings.bubbleRadius, min(newPosition.y, UIScreen.main.bounds.height - GameSettings.bubbleRadius))
            }
            
            // Update bubble position
            bubblePositions[index] = newPosition
        }
    }
    
}

extension CGPoint {
    static func distance(from a: CGPoint, to b: CGPoint) -> Double {
        return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
}

#Preview {
    PlayView()
        .environmentObject(GameSettings())
}
