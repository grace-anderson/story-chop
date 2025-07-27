import SwiftUI
import AVFoundation

struct StoryDetailModal: View {
    let story: Story
    @Environment(\.dismiss) private var dismiss
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Debug info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Story Title: \(story.title)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Prompt: \(story.prompt)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Duration: \(formatDuration(story.duration))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Story metadata
                VStack(alignment: .leading, spacing: 12) {
                    Text(story.prompt)
                        .font(.title3)
                        .italic()
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    HStack {
                        Label {
                            Text(story.date, style: .date)
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        Spacer()
                        Label {
                            Text(formatDuration(story.duration))
                        } icon: {
                            Image(systemName: "clock")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                // Playback controls
                VStack(spacing: 16) {
                    // Progress bar
                    VStack(spacing: 8) {
                        ProgressView(value: currentTime, total: story.duration)
                            .progressViewStyle(LinearProgressViewStyle())
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
                    
                    // Play/Pause button
                    Button(action: {
                        if isPlaying {
                            pauseAudio()
                        } else {
                            playAudio()
                        }
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.accentColor)
                    }
                    .accessibilityLabel(isPlaying ? "Pause audio" : "Play audio")
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
        }
    }
    
    private func setupAudioPlayer() {
        // For MVP, use placeholder logic since we don't have real audio files yet
        print("[DEBUG] Setting up audio player for file: \(story.filePath)")
        // TODO: Implement actual audio file loading when real recordings are available
    }
    
    private func playAudio() {
        print("[DEBUG] Playing audio for story: \(story.title)")
        isPlaying = true
        // TODO: Implement actual audio playback
        startTimer()
    }
    
    private func pauseAudio() {
        print("[DEBUG] Pausing audio for story: \(story.title)")
        isPlaying = false
        stopTimer()
    }
    
    private func stopAudio() {
        print("[DEBUG] Stopping audio for story: \(story.title)")
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if currentTime < story.duration {
                currentTime += 0.1
            } else {
                stopAudio()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func shareStory() {
        // TODO: Implement actual sharing with UIActivityViewController
        print("[DEBUG] Share functionality to be implemented")
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    StoryDetailModal(story: Story(
        title: "Sample Story",
        prompt: "Tell us about your first home",
        duration: 120.0,
        filePath: "/sample/path"
    ))
} 