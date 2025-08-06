import Foundation

// Shared state manager for selected prompt
class SelectedPromptManager: ObservableObject {
    static let shared = SelectedPromptManager()
    
    @Published var selectedPrompt: String? {
        didSet {
            if let prompt = selectedPrompt {
                UserDefaults.standard.set(prompt, forKey: "selectedPrompt")
                print("[DEBUG] SelectedPromptManager: Saved prompt to UserDefaults: \(prompt)")
            } else {
                UserDefaults.standard.removeObject(forKey: "selectedPrompt")
                print("[DEBUG] SelectedPromptManager: Removed prompt from UserDefaults")
            }
        }
    }
    
    private init() {
        // Load saved prompt from UserDefaults
        selectedPrompt = UserDefaults.standard.string(forKey: "selectedPrompt")
        print("[DEBUG] SelectedPromptManager: Loaded prompt from UserDefaults: \(selectedPrompt ?? "nil")")
    }
    
    func setSelectedPrompt(_ prompt: String) {
        print("[DEBUG] SelectedPromptManager: Setting selected prompt to: \(prompt)")
        selectedPrompt = prompt
    }
    
    func clearSelectedPrompt() {
        print("[DEBUG] SelectedPromptManager: Clearing selected prompt")
        selectedPrompt = nil
    }
} 