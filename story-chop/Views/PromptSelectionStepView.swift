import SwiftUI

struct PromptSelectionStepView: View {
    let featuredPrompt: String
    let onPromptSelected: (String) -> Void
    let onBrowseMore: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Featured prompt card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("This week's prompt")
                        .font(.subheadline)
                        .bold()
                }
                Text("\"\(featuredPrompt)\"")
                    .font(.title3)
                    .italic()
            }
            .padding()
            .background(Color.yellow.opacity(0.15))
            .cornerRadius(12)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Featured prompt: \(featuredPrompt)")
            
            // Ready to record button
            Button(action: {
                print("[DEBUG] I'm Ready to Record tapped")
                onPromptSelected(featuredPrompt)
            }) {
                HStack {
                    Image(systemName: "mic.fill")
                    Text("I'm Ready to Record")
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .accessibilityLabel("I'm ready to record with prompt: \(featuredPrompt)")
            
            // Browse more button
            Button(action: {
                print("[DEBUG] Browse more tapped")
                onBrowseMore()
            }) {
                Text("Browse more prompts")
                    .underline()
            }
            .accessibilityLabel("Browse more prompts")
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