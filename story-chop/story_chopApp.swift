//
//  story_chopApp.swift
//  story-chop
//
//  Created by Helen Anderson on 20/7/2025.
//

import SwiftUI
import SwiftData

@main
struct story_chopApp: App {
    // Set up the SwiftData model container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Prompt.self,
            PromptCategory.self
        ])
        let container = try! ModelContainer(for: schema)
        return container
    }()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
