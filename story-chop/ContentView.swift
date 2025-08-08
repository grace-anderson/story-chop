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
    // State to control tab selection
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(showNewStoryModal: $showNewStoryModal, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill") // Intuitive SF Symbol for Home
                    Text("Home")
                }
                .tag(0)
            PromptsView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "lightbulb.fill") // Intuitive SF Symbol for Prompts
                    Text("Prompts")
                }
                .tag(1)
            AllStoriesView()
                .tabItem {
                    Image(systemName: "list.bullet") // SF Symbol for Stories
                    Text("Stories")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill") // Intuitive SF Symbol for Settings
                    Text("Settings")
                }
                .tag(3)
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
