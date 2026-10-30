//
//  Dual_N_BackApp.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-30.
//

import SwiftUI

@main
struct Dual_N_BackApp: App {
    @StateObject private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
        }
    }
}
