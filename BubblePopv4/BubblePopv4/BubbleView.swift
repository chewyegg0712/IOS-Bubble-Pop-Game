//
//  BubbleView.swift
//  BubblePopv4
//
//  Created by JohnTSS on 10/4/2024.
//

import SwiftUI

struct BubbleView: View {
    var bubble: Bubble
    var position: CGPoint
    var onTap: () -> Void
    var body: some View {
        Circle()
            .fill(bubble.color) // Assuming Bubble has a SwiftUI Color property
            .frame(width: 50, height: 50)
            .position(position)
            .onTapGesture(perform: onTap)
    }
}

#Preview {
    BubbleView(
        bubble: Bubble(color: .red, points: 10, speed: 1.0, direction: CGPoint(x: 0, y: 1), baseSpeed: 1.0),
        position: CGPoint(x: 100, y: 100),
        onTap: {print("Bubble tapped!")})
}
