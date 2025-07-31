import SwiftUI

struct PromptSelectionStepView: View {
    let featuredPrompt: String
    let onPromptSelected: (String) -> Void
    let onBrowseMore: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Large blue circle button
            Button(action: {
                print("[DEBUG] I'm Ready to Record tapped")
                onPromptSelected(featuredPrompt)
            }) {
                VStack(spacing: 16) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    
                    Text("I'm Ready to Record")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 200, height: 200)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .accessibilityLabel("I'm ready to record with prompt: \(featuredPrompt)")
            
            Spacer()
        }
        .padding()
        .onAppear { print("[DEBUG] PromptSelectionStepView appeared") }
    }
}

#Preview {
    PromptSelectionStepView(
        featuredPrompt: "Tell us about your first home",
        onPromptSelected: { _ in },
        onBrowseMore: {}
    )
} 