import SwiftUI
import SwiftData

struct HomeView: View {
    // Binding to control modal presentation from parent
    @Binding var showNewStoryModal: Bool
    // Binding to control tab selection
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Story.date, order: .reverse) private var allStories: [Story]
    @State private var dailyPromptService: DailyPromptService
    
    init(showNewStoryModal: Binding<Bool>, selectedTab: Binding<Int>) {
        self._showNewStoryModal = showNewStoryModal
        self._selectedTab = selectedTab
        // Initialize dailyPromptService as a placeholder - will be set in onAppear
        self._dailyPromptService = State(initialValue: DailyPromptService(modelContext: ModelContext(try! ModelContainer(for: Prompt.self, PromptCategory.self))))
    }
    
    // Session-based prompt selection
    @State private var showPromptSelectionModal = false
    @StateObject private var selectedPromptManager = SelectedPromptManager.shared
    @State private var showSwitchToDailyPrompt = false
    
    // Current prompt to display (selected or daily)
    var currentPrompt: String {
        selectedPromptManager.selectedPrompt ?? dailyPromptService.currentDailyPrompt
    }
    
    // Whether to show selected prompt or daily prompt
    var isShowingSelectedPrompt: Bool {
        selectedPromptManager.selectedPrompt != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title and subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Stories")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Capture and preserve your memories")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    // Start New Story button
                    Button(action: {
                        print("[DEBUG] Start New Story button tapped")
                        showNewStoryModal = true
                    }) {
                        HStack {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 28))
                            Text("Start New Story")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(color: Color.green.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel("Start a new story")
                    // Prompt card (daily or selected)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: isShowingSelectedPrompt ? "person.fill" : "star.fill")
                                .foregroundColor(isShowingSelectedPrompt ? .blue : .yellow)
                            Text(isShowingSelectedPrompt ? "Your selected prompt" : "Today's prompt")
                                .font(.subheadline)
                                .bold()
                            
                            Spacer()
                            
                            // Show switch option if user has selected a prompt
                            if isShowingSelectedPrompt {
                                Button(action: {
                                    print("[DEBUG] Switching back to daily prompt")
                                    selectedPromptManager.clearSelectedPrompt()
                                }) {
                                    Text("Switch to daily")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        Text("\"\(currentPrompt)\"")
                            .font(.title3)
                            .italic()
                    }
                    .padding()
                    .background(isShowingSelectedPrompt ? Color.blue.opacity(0.15) : Color.yellow.opacity(0.15))
                    .cornerRadius(12)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(isShowingSelectedPrompt ? "Your selected prompt" : "Today's prompt"): \(currentPrompt)")
                    // Select a new prompt button
                    Button(action: {
                        print("[DEBUG] Select a new prompt tapped")
                        showPromptSelectionModal = true
                    }) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 20))
                            Text("Select a new prompt")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.orange.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .accessibilityLabel("Select a new prompt")
                    // View Stories button
                    Button(action: { 
                        print("[DEBUG] View Stories tapped - navigating to All Stories tab")
                        selectedTab = 2 // Switch to All Stories tab (tag 2)
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 20))
                            Text("View Stories")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .accessibilityLabel("View stories")

                }
                .padding()
            }
            .navigationTitle("Home")
            // Present modal when showNewStoryModal is true
            .sheet(isPresented: $showNewStoryModal) {
                NewStoryModalView(
                    onDismiss: {
                        showNewStoryModal = false
                    },
                    customPrompt: selectedPromptManager.selectedPrompt,
                    modelContext: modelContext
                )
            }
            // Present prompt selection modal
            .sheet(isPresented: $showPromptSelectionModal) {
                PromptSelectionModal(
                    onDismiss: {
                        showPromptSelectionModal = false
                    },
                    onPromptSelected: { prompt in
                        print("[DEBUG] Prompt selected from modal: \(prompt)")
                        selectedPromptManager.setSelectedPrompt(prompt)
                        showPromptSelectionModal = false
                    }
                )
            }
        }
        .onAppear {
            print("[DEBUG] HomeView appeared with \(allStories.count) total stories")
            print("[DEBUG] Current prompt: \(currentPrompt)")
            
            // Initialize dailyPromptService with the actual modelContext
            dailyPromptService = DailyPromptService(modelContext: modelContext)
            
            // Refresh the daily prompt cache to include any new prompts
            dailyPromptService.refreshCache()
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // If user navigated from Prompts tab (tag 1) to Home tab (tag 0), 
            // check if we need to update the selected prompt
            if oldValue == 1 && newValue == 0 {
                print("[DEBUG] User navigated from Prompts to Home")
                // The prompt selection is handled in PromptsView through the confirmation dialog
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d min", minutes, seconds)
    }
}

#Preview {
    // Use a constant binding for preview
    HomeView(showNewStoryModal: .constant(false), selectedTab: .constant(0))
} 
