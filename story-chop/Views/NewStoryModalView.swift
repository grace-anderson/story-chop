import SwiftUI
import AVFoundation

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
    // Audio recorder
    @State private var audioRecorder: AVAudioRecorder?
    // Recording file path
    @State private var recordingFilePath: String?
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
                                stopRecording()
                                saveStoryToSwiftData()
                                step = .saveConfirmation
                            },
                            onCancel: {
                                print("[DEBUG] Recording cancelled, returning to prompt selection")
                                stopRecording()
                                step = .promptSelection
                                recordingDuration = 0
                            }
                        )
                        .onChange(of: isRecording) { _, newValue in
                            if newValue {
                                startRecording()
                            } else {
                                stopRecording()
                            }
                        }
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
        .onAppear { 
            print("[DEBUG] NewStoryModalView appeared")
            setupAudioSession()
        }
        .onDisappear {
            stopRecording()
        }
    }
    
    private func setupAudioSession() {
        print("[DEBUG] Setting up audio session for recording")
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            print("[DEBUG] Audio session configured for recording")
        } catch {
            print("[DEBUG] Error configuring audio session: \(error)")
        }
    }
    
    private func startRecording() {
        print("[DEBUG] Starting audio recording")
        
        // Create a unique file path for the recording
        let fileName = "story_\(UUID().uuidString).m4a"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        recordingFilePath = fileURL.path
        
        print("[DEBUG] Recording file path: \(recordingFilePath ?? "nil")")
        
        // Configure recording settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = AudioRecorderDelegate()
            audioRecorder?.prepareToRecord()
            
            if audioRecorder?.record() == true {
                print("[DEBUG] Audio recording started successfully")
                startTimer()
            } else {
                print("[DEBUG] Failed to start audio recording")
            }
        } catch {
            print("[DEBUG] Error creating audio recorder: \(error)")
        }
    }
    
    private func stopRecording() {
        print("[DEBUG] Stopping audio recording")
        audioRecorder?.stop()
        stopTimer()
        isRecording = false
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingDuration += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func saveStoryToSwiftData() {
        guard let prompt = selectedPrompt, let filePath = recordingFilePath else { 
            print("[DEBUG] Cannot save story - missing prompt or file path")
            return 
        }
        
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
            print("[DEBUG] Audio file saved at: \(filePath)")
        } catch {
            print("[DEBUG] Error saving story to SwiftData: \(error)")
        }
    }
}



#Preview {
    NewStoryModalView()
} 