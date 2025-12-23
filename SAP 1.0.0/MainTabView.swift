//
//  MainTabView.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var appState = AppState()
    
    var body: some View {
        TabView {
            HomeView(appState: appState)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ProgressTrackingView(appState: appState)
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}

