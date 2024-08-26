//
//  Bubble.swift
//  BubblePopv4
//
//  Created by JohnTSS on 10/4/2024.
//

import Foundation
import SwiftUI
struct Bubble: Identifiable, Equatable{
    let id = UUID()
    var color: Color
    var points: Int
    var speed: CGFloat
    var direction: CGPoint
    var baseSpeed: CGFloat // Base speed at which the bubble moves
}
