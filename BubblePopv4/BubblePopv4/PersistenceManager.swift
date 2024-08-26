//
//  PersistenceManager.swift
//  BubblePopv4
//
//  Created by JohnTSS on 13/4/2024.
//

import Foundation
class PersistenceManager {
    static let shared = PersistenceManager()
    private let fileName = "highscores.json"
    private var scores: [HighScore] = []

    init() {
        loadScores()
    }
    
    func getHighestScore() -> Int? {
        return scores.map { $0.score }.max()
    }
    
    func saveScore(_ score: HighScore) {
        if let index = scores.firstIndex(where: { $0.name == score.name && $0.score < score.score }) {
            scores[index].score = score.score // Update only if the new score is higher
        } else if !scores.contains(where: { $0.name == score.name }) {
            scores.append(score) // Append if it's a new player
        }
        saveScores()
    }

    private func saveScores() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(scores) {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
            try? data.write(to: url)
        }
    }

    private func loadScores() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url),
           let savedScores = try? JSONDecoder().decode([HighScore].self, from: data) {
            scores = savedScores
        }
    }

    func getTopScores(limit: Int = 10) -> [HighScore] {
        return scores.sorted { $0.score > $1.score }.prefix(limit).map { $0 }
    }
}
