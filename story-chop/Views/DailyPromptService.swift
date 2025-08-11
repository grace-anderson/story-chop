import Foundation
import SwiftData

@Observable final class DailyPromptService {
    private let userDefaults = UserDefaults.standard
    private let dailyPromptKey = "dailyPrompt"
    private let dailyPromptDateKey = "dailyPromptDate"
    private let modelContext: ModelContext
    
    // Fallback prompts if SwiftData is empty
    private let fallbackPrompts = [
        "Tell us about your first home",
        "Who inspired you as a child?",
        "Describe a favorite family tradition",
        "What was your first job?",
        "Share a memorable holiday experience"
    ]
    
    // Cached prompts from SwiftData
    private var cachedPrompts: [String] = []
    private var lastCacheUpdate: Date?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        print("[DEBUG] DailyPromptService initialized with ModelContext")
    }
    
    var currentDailyPrompt: String {
        get {
            // Check if we need to update the daily prompt
            if shouldUpdateDailyPrompt() {
                updateDailyPrompt()
            }
            
            // Return the stored prompt or a fallback
            return userDefaults.string(forKey: dailyPromptKey) ?? getRandomPrompt() ?? "Share a memory!"
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
        
        // Get all available prompts from SwiftData with fallback
        let allPrompts = getAllAvailablePrompts()
        
        // Select a random prompt
        let selectedPrompt = allPrompts.randomElement() ?? "Share a memory!"
        
        // Store the prompt and update date
        userDefaults.set(selectedPrompt, forKey: dailyPromptKey)
        userDefaults.set(Date(), forKey: dailyPromptDateKey)
        
        print("[DEBUG] Daily prompt updated to: \(selectedPrompt)")
    }
    
    // Method to get all available prompts from SwiftData with fallback
    private func getAllAvailablePrompts() -> [String] {
        // Check if we need to refresh the cache
        if shouldRefreshCache() {
            refreshPromptCache()
        }
        
        // Return cached prompts if available, otherwise fallback
        if !cachedPrompts.isEmpty {
            print("[DEBUG] Using cached prompts: \(cachedPrompts.count) prompts")
            return cachedPrompts
        } else {
            print("[DEBUG] No cached prompts, using fallback prompts")
            return fallbackPrompts
        }
    }
    
    // Method to get a random prompt from available prompts
    private func getRandomPrompt() -> String? {
        let allPrompts = getAllAvailablePrompts()
        return allPrompts.randomElement()
    }
    
    // Check if cache needs refreshing
    private func shouldRefreshCache() -> Bool {
        guard let lastUpdate = lastCacheUpdate else { return true }
        
        // Refresh cache if it's older than 1 hour or if we don't have any cached prompts
        let oneHourAgo = Date().addingTimeInterval(-3600)
        return lastUpdate < oneHourAgo || cachedPrompts.isEmpty
    }
    
    // Refresh the prompt cache from SwiftData
    private func refreshPromptCache() {
        print("[DEBUG] Refreshing prompt cache")
        
        do {
            // Fetch all prompts from SwiftData
            let fetchDescriptor = FetchDescriptor<Prompt>()
            let allPrompts = try modelContext.fetch(fetchDescriptor)
            
            // Extract prompt text from all prompts
            let promptTexts = allPrompts.map { $0.text }
            
            // Update cache
            cachedPrompts = promptTexts
            lastCacheUpdate = Date()
            
            print("[DEBUG] Cache refreshed with \(promptTexts.count) prompts")
            
        } catch {
            print("[DEBUG] Error fetching prompts from SwiftData: \(error)")
            // Keep existing cache or use fallback
            if cachedPrompts.isEmpty {
                cachedPrompts = fallbackPrompts
                lastCacheUpdate = Date()
                print("[DEBUG] Using fallback prompts due to fetch error")
            }
        }
    }
    
    // Public method to manually refresh cache (useful when new prompts are added)
    func refreshCache() {
        print("[DEBUG] Manually refreshing prompt cache")
        refreshPromptCache()
    }
    
    // Method to refresh the daily prompt (for testing purposes)
    func refreshDailyPrompt() {
        print("[DEBUG] Manually refreshing daily prompt")
        updateDailyPrompt()
    }
} 