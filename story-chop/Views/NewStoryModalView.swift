import SwiftUI

// Enum for modal steps
private enum NewStoryStep {
    case promptSelection
    case recording
    case saveConfirmation
}

struct NewStoryModalView: View {
    // Step state
    @State private var step: NewStoryStep = .promptSelection
    // Selected prompt
    @State private var selectedPrompt: String? = nil
    // Recording duration (seconds)
    @State private var recordingDuration: Int = 0
    // Is recording active
    @State private var isRecording: Bool = false
    // Timer for recording
    @State private var timer: Timer? = nil
    // SwiftData context
    @Environment(\.modelContext) private var modelContext
    // Static prompt list
    let prompts = [
        "Tell us about your first home",
        "Who inspired you as a child?",
        "Describe a favorite family tradition",
        "What was your first job?",
        "Share a memorable holiday experience"
    ]
    // Randomly select a featured prompt
    var featuredPrompt: String {
        prompts.randomElement() ?? "Share a memory!"
    }
    var body: some View {
        NavigationView {
            VStack {
                // Debug info
                Text("Step: \(String(describing: step))")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top)
                
                switch step {
                case .promptSelection:
                    PromptSelectionStepView(
                        featuredPrompt: featuredPrompt,
                        onPromptSelected: { prompt in
                            print("[DEBUG] Prompt selected: \(prompt)")
                            selectedPrompt = prompt
                            step = .recording
                        },
                        onBrowseMore: {
                            // For MVP, just pick a random prompt
                            let prompt = prompts.randomElement() ?? "Share a memory!"
                            print("[DEBUG] Browse more tapped, picked: \(prompt)")
                            selectedPrompt = prompt
                        }
                    )
                case .recording:
                    if let prompt = selectedPrompt {
                        RecordingStepView(
                            prompt: prompt,
                            isRecording: $isRecording,
                            duration: $recordingDuration,
                            onSave: {
                                print("[DEBUG] Recording saved. Duration: \(recordingDuration)s")
                                saveStoryToSwiftData()
                                step = .saveConfirmation
                            },
                            onCancel: {
                                print("[DEBUG] Recording cancelled, returning to prompt selection")
                                step = .promptSelection
                                recordingDuration = 0
                            }
                        )
                    }
                case .saveConfirmation:
                    SaveConfirmationStepView(onDone: {
                        print("[DEBUG] Save confirmation done, dismiss modal")
                        // Dismissal handled by parent sheet
                    })
                }
            }
            .padding()
            .navigationTitle("New Story")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { print("[DEBUG] NewStoryModalView appeared") }
    }
    
    private func saveStoryToSwiftData() {
        guard let prompt = selectedPrompt else { return }
        
        // Create a unique file path for the recording
        let fileName = "story_\(UUID().uuidString).m4a"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent(fileName).path
        
        // Create Story object and save to SwiftData
        let story = Story(
            title: prompt, // Auto-assign title from prompt
            prompt: prompt,
            duration: TimeInterval(recordingDuration),
            filePath: filePath,
            isShared: false
        )
        
        modelContext.insert(story)
        
        do {
            try modelContext.save()
            print("[DEBUG] Story saved to SwiftData: \(story.title) with duration: \(story.duration)s")
        } catch {
            print("[DEBUG] Error saving story to SwiftData: \(error)")
        }
    }
}

#Preview {
    NewStoryModalView()
} 