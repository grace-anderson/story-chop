import SwiftUI

struct RecordingStepView: View {
    let prompt: String
    @Binding var isRecording: Bool
    @Binding var duration: Int
    let onSave: () -> Void
    let onCancel: () -> Void
    
    // Timer publisher for updating duration
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack(spacing: 32) {
            // Show prompt
            Text(prompt)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .accessibilityLabel("Prompt: \(prompt)")
            
            // Timer display
            Text(String(format: "%02d:%02d", duration / 60, duration % 60))
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding(.bottom, 8)
                .accessibilityLabel("Recording duration: \(duration) seconds")
            
            // Record/Stop button
            Button(action: {
                isRecording.toggle()
                if isRecording {
                    print("[DEBUG] Recording started")
                    startTimer()
                } else {
                    print("[DEBUG] Recording stopped")
                    stopTimer()
                }
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(isRecording ? .red : .green)
                    .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
            }
            
            // Save button (enabled after 5 seconds)
            Button(action: {
                print("[DEBUG] Save tapped")
                stopTimer()
                onSave()
            }) {
                Text("Save Recording")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(duration >= 5 ? Color.accentColor : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(duration < 5)
            .accessibilityLabel("Save recording")
            
            // Cancel button
            Button(action: {
                print("[DEBUG] Cancel tapped")
                stopTimer()
                onCancel()
            }) {
                Text("Cancel")
                    .foregroundColor(.red)
            }
            .accessibilityLabel("Cancel recording")
        }
        .padding()
        .onAppear {
            print("[DEBUG] RecordingStepView appeared")
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // Timer logic
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            duration += 1
        }
    }
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    RecordingStepView(
        prompt: "Tell us about your first home",
        isRecording: .constant(false),
        duration: .constant(0),
        onSave: {},
        onCancel: {}
    )
} 