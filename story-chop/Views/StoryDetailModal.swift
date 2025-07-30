import SwiftUI
import AVFoundation

struct StoryDetailModal: View {
    let story: Story
    @Environment(\.dismiss) private var dismiss
    
    // Audio playback state
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioPlayerDelegate: AudioPlayerDelegate?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isPlayButtonEnabled = true
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // Transcription state
    @State private var transcriptionService = TranscriptionService()
    @State private var showTranscriptionModal = false
    @State private var showTranscriptionErrorAlert = false
    
    // Sharing state
    @State private var sharingService = SharingService()
    @State private var showSharingErrorAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Debug info section (can be removed later)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug Info:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Title: \(story.title)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Prompt: \(story.prompt)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Duration: \(formatDuration(story.duration))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("File Path: \(story.filePath)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Story content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Prompt:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(story.prompt)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    HStack {
                        Label("Recorded \(formatDate(story.date))", systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Label("Duration: \(formatDuration(story.duration))", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Audio playback controls
                VStack(spacing: 16) {
                    // Play/Pause button
                    Button(action: {
                        if isPlaying {
                            pauseAudio()
                        } else {
                            playAudio()
                        }
                    }) {
                        HStack {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                            Text(isPlaying ? "Pause" : "Play")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isPlayButtonEnabled ? Color.accentColor : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isPlayButtonEnabled)
                    .accessibilityLabel(isPlaying ? "Pause audio" : "Play audio")
                    
                    // Progress bar and time display
                    VStack(spacing: 8) {
                        ProgressView(value: story.duration > 0 ? currentTime / story.duration : 0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                        
                        HStack {
                            Text(formatDuration(currentTime))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formatDuration(story.duration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Share button
                Button(action: {
                    print("[DEBUG] Share button tapped for story: \(story.title)")
                    shareStory()
                }) {
                    Label("Share Story", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .accessibilityLabel("Share story")
                
                // Transcription button
                Button(action: {
                    print("[DEBUG] Transcription button tapped for story: \(story.title)")
                    handleTranscriptionButtonTap()
                }) {
                    Label(story.isTranscribed ? "Transcription" : "Transcribe", systemImage: "text.bubble")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(story.isTranscribed ? Color.green : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(transcriptionService.isTranscribing)
                .accessibilityLabel(story.isTranscribed ? "View transcription" : "Transcribe audio")
                
                Spacer()
            }
            .padding()
            .navigationTitle(story.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        print("[DEBUG] Story detail modal dismissed")
                        stopAudio()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            print("[DEBUG] StoryDetailModal appeared for story: \(story.title)")
            print("[DEBUG] Story data - title: \(story.title), prompt: \(story.prompt), duration: \(story.duration)")
            setupAudioPlayer()
        }
        .onDisappear {
            stopAudio()
            cleanupAudioPlayer()
        }
        .alert("Playback Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Something went wrong", isPresented: $showTranscriptionErrorAlert) {
            Button("OK") { }
        }
        .alert("Audio file not found", isPresented: $showSharingErrorAlert) {
            Button("OK") { }
        }
        .sheet(isPresented: $showTranscriptionModal) {
            if let transcription = story.transcription {
                TranscriptionModal(transcription: transcription)
            }
        }
    }
    
    private func setupAudioPlayer() {
        print("[DEBUG] Setting up audio player for file: \(story.filePath)")
        
        // Configure audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("[DEBUG] Audio session configured for playback")
        } catch {
            print("[DEBUG] Error configuring audio session: \(error)")
            showPlaybackError("Failed to configure audio session: \(error.localizedDescription)")
            return
        }
        
        // Check if file exists
        let fileURL = URL(fileURLWithPath: story.filePath)
        guard FileManager.default.fileExists(atPath: story.filePath) else {
            print("[DEBUG] Audio file not found at path: \(story.filePath)")
            showPlaybackError("Audio file not found. The recording may have been deleted or moved.")
            return
        }
        
        // Create and configure AVAudioPlayer
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            
            // Create and store the delegate as a strong reference
            audioPlayerDelegate = AudioPlayerDelegate { _ in
                // Handle playback completion
                DispatchQueue.main.async {
                    print("[DEBUG] Audio playback completed")
                    isPlaying = false
                    currentTime = 0
                    stopTimer()
                }
            }
            
            audioPlayer?.delegate = audioPlayerDelegate
            audioPlayer?.prepareToPlay()
            print("[DEBUG] Audio player setup successful")
        } catch {
            print("[DEBUG] Error creating audio player: \(error)")
            showPlaybackError("Failed to load audio file: \(error.localizedDescription)")
        }
    }
    
    private func playAudio() {
        guard let player = audioPlayer, isPlayButtonEnabled else { return }
        
        print("[DEBUG] Playing audio for story: \(story.title)")
        
        if player.play() {
            isPlaying = true
            startTimer()
            print("[DEBUG] Audio playback started successfully")
        } else {
            print("[DEBUG] Failed to start audio playback")
            showPlaybackError("Failed to start audio playback")
        }
    }
    
    private func pauseAudio() {
        print("[DEBUG] Pausing audio for story: \(story.title)")
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    private func stopAudio() {
        print("[DEBUG] Stopping audio for story: \(story.title)")
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = audioPlayer else { return }
            currentTime = player.currentTime
            
            // Check if playback has finished (either reached end or stopped)
            if currentTime >= story.duration || !player.isPlaying {
                print("[DEBUG] Playback finished - currentTime: \(currentTime), duration: \(story.duration)")
                isPlaying = false
                currentTime = 0
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func cleanupAudioPlayer() {
        print("[DEBUG] Cleaning up audio player")
        stopAudio()
        audioPlayer = nil
        audioPlayerDelegate = nil
    }
    
    private func showPlaybackError(_ message: String) {
        print("[DEBUG] Playback error: \(message)")
        errorMessage = message
        isPlayButtonEnabled = false
        showErrorAlert = true
    }
    
    // MARK: - Sharing Functions
    
    private func shareStory() {
        print("[DEBUG] Share button tapped for story: \(story.title)")
        
        let result = sharingService.prepareStoryForSharing(story: story)
        
        switch result {
        case .success(let shareItems):
            print("[DEBUG] Share items prepared successfully, showing activity view")
            presentActivityViewController(with: shareItems)
        case .failure(let error):
            print("[DEBUG] Sharing failed: \(error)")
            showSharingErrorAlert = true
        }
    }
    
    private func presentActivityViewController(with items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Configure activity view controller
        activityViewController.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks,
            .markupAsPDF
        ]
        
        // Present the activity view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true) {
                print("[DEBUG] Activity view controller presented")
            }
        }
        
        // Handle completion
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[DEBUG] Activity view controller error: \(error)")
                }
                
                if completed {
                    print("[DEBUG] Story shared successfully via: \(activityType?.rawValue ?? "unknown")")
                } else {
                    print("[DEBUG] Story sharing cancelled")
                }
                
                // Clean up shared file if it was created
                if let fileURL = items.first as? URL {
                    self.sharingService.cleanupSharedFile(at: fileURL)
                }
            }
        }
    }
    
    // MARK: - Transcription Functions
    
    private func handleTranscriptionButtonTap() {
        if story.isTranscribed {
            // Show existing transcription
            print("[DEBUG] Showing existing transcription for story: \(story.title)")
            showTranscriptionModal = true
        } else {
            // Start new transcription
            print("[DEBUG] Starting new transcription for story: \(story.title)")
            startTranscription()
        }
    }
    
    private func startTranscription() {
        transcriptionService.transcribeAudio(filePath: story.filePath) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transcribedText):
                    print("[DEBUG] Transcription successful for story: \(self.story.title)")
                    self.saveTranscription(transcribedText)
                case .failure(let error):
                    print("[DEBUG] Transcription failed for story: \(self.story.title), error: \(error)")
                    self.showTranscriptionErrorAlert = true
                }
            }
        }
    }
    
    private func saveTranscription(_ transcription: String) {
        // Update the story with transcription data
        story.transcription = transcription
        story.isTranscribed = true
        print("[DEBUG] Transcription saved for story: \(story.title)")
        
        // Show the transcription modal
        showTranscriptionModal = true
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}



#Preview {
    StoryDetailModal(story: Story(
        title: "Sample Story",
        prompt: "Tell us about your first home",
        duration: 120.0,
        filePath: "/sample/path",
        transcription: "This is a sample transcription of the audio recording.",
        isTranscribed: true
    ))
} 