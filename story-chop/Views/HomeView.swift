import SwiftUI

struct HomeView: View {
    // Binding to control modal presentation from parent
    @Binding var showNewStoryModal: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Placeholder for story list
                Text("[Home] Your saved stories will appear here.")
                    .font(.title2)
                    .padding()
                
                // Start New Story button
                Button(action: {
                    print("[DEBUG] Start New Story button tapped")
                    showNewStoryModal = true
                }) {
                    Text("Start New Story")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .accessibilityLabel("Start a new story")
                }
                .padding(.horizontal)
            }
            .navigationTitle("Home")
            // Present modal when showNewStoryModal is true
            .sheet(isPresented: $showNewStoryModal) {
                // Placeholder modal content
                VStack {
                    Text("[Modal] New Story Flow Coming Soon!")
                        .font(.title)
                        .padding()
                    Button("Close") {
                        print("[DEBUG] Modal closed")
                        showNewStoryModal = false
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            print("[DEBUG] HomeView appeared")
        }
    }
}

#Preview {
    // Use a constant binding for preview
    HomeView(showNewStoryModal: .constant(false))
} 