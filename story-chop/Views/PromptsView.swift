import SwiftUI

struct PromptsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("[Prompts] Browse or select prompts here.")
                    .font(.title2)
                    .padding()
            }
            .navigationTitle("Prompts")
        }
        .onAppear {
            print("[DEBUG] PromptsView appeared")
        }
    }
}

#Preview {
    PromptsView()
} 