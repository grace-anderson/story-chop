import SwiftUI

struct TranscriptionModal: View {
    let transcription: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Transcription content
                    Text(transcription)
                        .font(.body)
                        .lineSpacing(4)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Transcription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        print("[DEBUG] Transcription modal dismissed")
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            print("[DEBUG] TranscriptionModal appeared with text length: \(transcription.count)")
        }
    }
}

#Preview {
    TranscriptionModal(transcription: "This is a sample transcription text that would be displayed in the modal. It shows how the transcribed audio content would appear to the user.")
} 