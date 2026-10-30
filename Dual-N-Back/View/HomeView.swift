//
//  HomeView.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-30.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Dual N-Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Train your working memory")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                NavigationLink(destination: GameView()) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GameViewModel())
}
