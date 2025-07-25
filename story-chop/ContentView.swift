//
//  ContentView.swift
//  story-chop
//
//  Created by Helen Anderson on 20/7/2025.
//

import SwiftUI

struct ContentView: View {
    // Debug log for view initialization
    init() {
        print("[DEBUG] ContentView initialized")
    }
    
    // State to control the modal presentation for 'Start New Story'
    @State private var showNewStoryModal = false
    
    var body: some View {
        TabView {
            HomeView(showNewStoryModal: $showNewStoryModal)
                .tabItem {
                    Image(systemName: "house.fill") // Intuitive SF Symbol for Home
                    Text("Home")
                }
            PromptsView()
                .tabItem {
                    Image(systemName: "lightbulb.fill") // Intuitive SF Symbol for Prompts
                    Text("Prompts")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill") // Intuitive SF Symbol for Settings
                    Text("Settings")
                }
        }
        // Debug log for tab selection
        .onAppear {
            print("[DEBUG] TabView appeared")
        }
        // Modal presentation for 'Start New Story' (handled in HomeView)
    }
}

#Preview {
    ContentView()
}
