//
//  HighScore.swift
//  BubblePopv4
//
//  Created by JohnTSS on 13/4/2024.
//

import Foundation
struct HighScore: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var score: Int
}
