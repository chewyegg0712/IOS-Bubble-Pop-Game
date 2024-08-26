//
//  HighScoreBoardView.swift
//  BubblePopv4
//
//  Created by JohnTSS on 10/4/2024.
//

import SwiftUI

struct HighScoreBoardView: View {
    @State private var topScores: [HighScore] = []
    
    var body: some View {
        List(topScores, id: \.id) { score in
            HStack {
                Text(score.name).bold()
                Spacer()
                Text("\(score.score) Points")
            }
        }
        .onAppear {
            topScores = PersistenceManager.shared.getTopScores()
        }
        .navigationBarTitle("High Scores", displayMode: .inline)
    }
}

#Preview {
    HighScoreBoardView()
}
