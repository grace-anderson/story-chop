import SwiftUI
import AVFoundation

// Enum for modal steps
private enum NewStoryStep {
    case recording
    case saveConfirmation
}

struct NewStoryModalView: View {
    let onDismiss: () -> Void
    let customPrompt: String? // Optional custom prompt to use instead of daily prompt
    
    // Step state
    @State private var step: NewStoryStep = .recording
    // Selected prompt - use custom prompt if provided, otherwise daily prompt
    @State private var selectedPrompt: String
    // Recording duration (seconds)
    @State private var recordingDuration: Int = 0
    // Is recording active
    @State private var isRecording: Bool = false
    // Timer for recording
    @State private var timer: Timer? = nil
    // Audio recorder
    @State private var audioRecorder: AVAudioRecorder?
    // Audio recorder delegate (strong reference to prevent deallocation)
    @State private var audioRecorderDelegate: AudioRecorderDelegate?
    // Recording file path
    @State private var recordingFilePath: String?
    // SwiftData context
    @Environment(\.modelContext) private var modelContext
    // Daily prompt service
    @State private var dailyPromptService = DailyPromptService()
    
    // Initialize with custom prompt or daily prompt
    init(onDismiss: @escaping () -> Void, customPrompt: String? = nil) {
        self.onDismiss = onDismiss
        self.customPrompt = customPrompt
        
        let dailyPromptService = DailyPromptService()
        let initialPrompt = customPrompt ?? dailyPromptService.currentDailyPrompt
        self._selectedPrompt = State(initialValue: initialPrompt)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                switch step {
                case .recording:
                    RecordingStepView(
                        prompt: selectedPrompt,
                        isRecording: $isRecording,
                        duration: $recordingDuration,
                        onSave: {
                            print("[DEBUG] Recording saved. Duration: \(recordingDuration)s")
                            stopRecording()
                            saveStoryToSwiftData()
                            step = .saveConfirmation
                        },
                        onCancel: {
                            print("[DEBUG] Recording cancelled, dismissing modal")
                            stopRecording()
                            onDismiss()
                        }
                    )
                    .onChange(of: isRecording) { _, newValue in
                        if newValue {
                            startRecording()
                        } else {
                            stopRecording()
                        }
                    }
                case .saveConfirmation:
                    SaveConfirmationStepView(onDone: {
                        print("[DEBUG] Save confirmation done, dismiss modal")
                        onDismiss() // Dismiss the entire modal flow
                    })
                }
            }
            .padding()
            .navigationTitle("New Story")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { 
            print("[DEBUG] NewStoryModalView appeared with prompt: \(selectedPrompt)")
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
            // Create and store the delegate as a strong reference
            audioRecorderDelegate = AudioRecorderDelegate()
            audioRecorder?.delegate = audioRecorderDelegate
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
        guard let filePath = recordingFilePath else { 
            print("[DEBUG] Cannot save story - missing file path")
            return 
        }
        
        // Create Story object and save to SwiftData
        let story = Story(
            title: selectedPrompt, // Auto-assign title from prompt
            prompt: selectedPrompt,
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
    NewStoryModalView(onDismiss: {})
} 