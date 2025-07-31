import Foundation
import SwiftData

@Observable final class DailyPromptService {
    private let userDefaults = UserDefaults.standard
    private let dailyPromptKey = "dailyPrompt"
    private let dailyPromptDateKey = "dailyPromptDate"
    
    // Built-in prompts (same as in NewStoryModalView)
    private let builtInPrompts = [
        "Tell us about your first home",
        "Who inspired you as a child?",
        "Describe a favorite family tradition",
        "What was your first job?",
        "Share a memorable holiday experience"
    ]
    
    var currentDailyPrompt: String {
        get {
            // Check if we need to update the daily prompt
            if shouldUpdateDailyPrompt() {
                updateDailyPrompt()
            }
            
            // Return the stored prompt or a fallback
            return userDefaults.string(forKey: dailyPromptKey) ?? builtInPrompts.randomElement() ?? "Share a memory!"
        }
    }
    
    private func shouldUpdateDailyPrompt() -> Bool {
        guard let lastUpdateDate = userDefaults.object(forKey: dailyPromptDateKey) as? Date else {
            return true // No previous update, need to set initial prompt
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check if we've crossed midnight since the last update
        return !calendar.isDate(lastUpdateDate, inSameDayAs: now)
    }
    
    private func updateDailyPrompt() {
        print("[DEBUG] Updating daily prompt")
        
        // Get all available prompts (built-in + user-added)
        let allPrompts = builtInPrompts
        
        // TODO: Add user-added prompts from SwiftData when we have access to modelContext
        // For now, we'll use a placeholder that can be expanded later
        // let userPrompts = getCurrentUserPrompts()
        // allPrompts.append(contentsOf: userPrompts)
        
        // Select a random prompt
        let selectedPrompt = allPrompts.randomElement() ?? "Share a memory!"
        
        // Store the prompt and update date
        userDefaults.set(selectedPrompt, forKey: dailyPromptKey)
        userDefaults.set(Date(), forKey: dailyPromptDateKey)
        
        print("[DEBUG] Daily prompt updated to: \(selectedPrompt)")
    }
    
    // Method to get user-added prompts (to be implemented when we have modelContext access)
    private func getCurrentUserPrompts() -> [String] {
        // This will be implemented to fetch user-added prompts from SwiftData
        // For now, return empty array
        return []
    }
    
    // Method to refresh the daily prompt (for testing purposes)
    func refreshDailyPrompt() {
        print("[DEBUG] Manually refreshing daily prompt")
        updateDailyPrompt()
    }
} 