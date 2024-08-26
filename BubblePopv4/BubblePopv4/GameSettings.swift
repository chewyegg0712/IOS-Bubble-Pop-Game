//
//  GameSettings.swift
//  BubblePopv4
//
//  Created by JohnTSS on 10/4/2024.
//

import Foundation
import Combine
import SwiftUI

class GameSettings: ObservableObject {
    @Published var gameTime: Double = 60
    @Published var maxBubbles: Double = 15
    @Published var currentScore: Int = 0
    @Published var timeLeft: Int = 60
    @Published var bubbles: [Bubble] = []
    @Published var bubblePositions: [CGPoint] = []
    @Published var lastPoppedColor: Color? = nil
    @Published var consecutivePopCount: Int = 0
    @Published var playerName: String = ""
    @Published var gameOver: Bool = false
    @Published var countdown: Int = 3
    @Published var showCountdown: Bool = true
    @Published var highestScore: Int = 0
    
    var timer: AnyCancellable?
    init() {
        loadGameSettings()
    }
    
    private func loadGameSettings() {
        highestScore = PersistenceManager.shared.getHighestScore() ?? 0
    }
    
    func startCountdown() {
        showCountdown = true
        countdown = 3  // Start countdown from 3
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                self.showCountdown = false
                self.startGame()  // Start the game after countdown
            }
        }
    }
    
    func startGame(){
        gameOver = false
        currentScore = 0
        setupBubbles()
        startTimer()
    }
    
    func endGame(){
        timer?.cancel()
        gameOver = true
        // Update the highest score if the current score is greater
        if currentScore > highestScore {
            highestScore = currentScore
        }
        PersistenceManager.shared.saveScore(HighScore(id: UUID(), name: playerName, score: currentScore))
    }
    
    private func startTimer() {
        timer?.cancel() // Cancel any existing timer
        timeLeft = Int(gameTime)  // Reset the timer to the full game time
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            if self.timeLeft > 0 {
                self.timeLeft -= 1
                self.refreshBubbles() // Call this method to refresh bubbles every second
                self.adjustBubbleSpeeds()
            } else {
                endGame()
            }
        }
    }
    
    func setupBubbles() {
        refreshBubbles()
    }
    
    // Define bubble types with probabilities and points
    private let bubbleTypes = [
        (color: Color.red, points: 1, cumulativeProbability: 0.40),
        (color: Color.pink, points: 2, cumulativeProbability: 0.70),
        (color: Color.green, points: 5, cumulativeProbability: 0.85),
        (color: Color.blue, points: 8, cumulativeProbability: 0.95),
        (color: Color.black, points: 10, cumulativeProbability: 1.00)
    ]
    
    func refreshBubbles() {
        DispatchQueue.main.async {
            var refreshedBubbles = [Bubble]()
            let retentionProbability = 0.70  // 70% chance to retain a bubble, adjust as needed
            
            // Retain some of the existing bubbles
            for bubble in self.bubbles {
                if Double.random(in: 0..<1) < retentionProbability {
                    refreshedBubbles.append(bubble)
                }
            }
            
            // Add new bubbles to reach the max count
            let neededBubbles = Int(self.maxBubbles) - refreshedBubbles.count
            if neededBubbles > 0 {
                refreshedBubbles.append(contentsOf: self.getRandomBubbles(totalBubbles: neededBubbles))
            }
            
            // Make sure new positions are recalculated to prevent overlap
            self.bubbles = refreshedBubbles
            self.recalculatePositions()
        }
        
    }
    
    func recalculatePositions() {
        let screenSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)  // Get screen size
        bubblePositions = calculateNonOverlappingPositions(count: bubbles.count, in: screenSize)
    }
    
    func getRandomBubbles(totalBubbles: Int) -> [Bubble] {
        var bubbles: [Bubble] = []
        for _ in 0..<totalBubbles {
            let randomValue = Double.random(in: 0..<1)
            let selectedType = bubbleTypes.first(where: { $0.cumulativeProbability >= randomValue })!
            
            let baseSpeed = CGFloat.random(in: 0.5...2.0)
            let direction = CGPoint(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -1...1)).normalized() // Normalize to keep speed consistent
            
            bubbles.append(Bubble(color: selectedType.color, points: selectedType.points, speed: baseSpeed, direction: direction, baseSpeed: baseSpeed))
        }
        return bubbles
    }
    
    func adjustBubbleSpeeds() {
        let speedIncreaseFactor = 1 + (0.05 * (60 - Double(timeLeft)) / 60) // Increase speed by 5% of the initial speed per second passed
        for i in 0..<bubbles.count {
            bubbles[i].speed = bubbles[i].baseSpeed * CGFloat(speedIncreaseFactor)
        }
    }
    
    func popBubble(bubble: Bubble) {
        if lastPoppedColor == bubble.color {
            consecutivePopCount += 1
        } else {
            lastPoppedColor = bubble.color
            consecutivePopCount = 1
        }
        let additionalPoints = round(Double(bubble.points) * (1.0 + 0.5 * Double(consecutivePopCount - 1)))
        currentScore += Int(additionalPoints)
        bubbles.removeAll { $0.id == bubble.id }
    }
    
    static let bubbleRadius: CGFloat = 25.0 // Used as the radius for bubbles throughout the app
    
    func calculateNonOverlappingPositions(count: Int, in size: CGSize) -> [CGPoint] {
        var positions = [CGPoint]()
        let radius = GameSettings.bubbleRadius // Assume this is the radius of the bubbles
        var attemptCount = 0  // To prevent infinite loops
        
        while positions.count < count {
            var newPosition: CGPoint
            var overlap: Bool
            repeat {
                // Generate a new position ensuring the bubble stays within the screen boundaries
                newPosition = CGPoint(
                    x: CGFloat.random(in: radius..<(size.width - radius)),
                    y: CGFloat.random(in: radius..<(size.height - radius))
                )
                overlap = positions.contains { existingPosition in
                    CGPoint.distance(from: existingPosition, to: newPosition) < radius * 2
                }
                attemptCount += 1
                if attemptCount > 50 {  // Break after too many failed attempts to find a non-overlapping position
                    break
                }
            } while overlap
            
            if attemptCount <= 50 {
                positions.append(newPosition)
            }
        }
        return positions
    }
}

extension CGPoint {
    /// Returns a new point representing the unit vector of the original point.
    func normalized() -> CGPoint {
        let length = sqrt(x * x + y * y)
        guard length != 0 else { return CGPoint(x: 0, y: 0) }  // Avoid division by zero
        return CGPoint(x: x / length, y: y / length)
    }
}
