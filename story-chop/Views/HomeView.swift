import SwiftUI

struct HomeView: View {
    // Binding to control modal presentation from parent
    @Binding var showNewStoryModal: Bool
    // Static recent stories for scaffolding
    let recentStories = [
        (title: "My childhood summer memories", date: "Dec 18, 2024", duration: "4:32 min", shared: true),
        (title: "The day I met your grandmother", date: "Dec 15, 2024", duration: "7:18 min", shared: false),
        (title: "Learning to drive in 1962", date: "Dec 12, 2024", duration: "3:45 min", shared: true),
        (title: "My first job at the factory", date: "Dec 10, 2024", duration: "6:22 min", shared: false),
        (title: "The best advice I ever received", date: "Dec 8, 2024", duration: "2:15 min", shared: false)
    ]
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title and subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Stories")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Capture and preserve your memories")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    // Start New Story button
                    Button(action: {
                        print("[DEBUG] Start New Story button tapped")
                        showNewStoryModal = true
                    }) {
                        HStack {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 28))
                            Text("Start New Story")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(color: Color.green.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel("Start a new story")
                    // Featured prompt card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("This week's prompt")
                                .font(.subheadline)
                                .bold()
                        }
                        Text("\"Tell us about your first home\"")
                            .font(.title3)
                            .italic()
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.15))
                    .cornerRadius(12)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Featured prompt: Tell us about your first home")
                    // Browse more button
                    Button(action: {
                        print("[DEBUG] Browse more prompts tapped")
                        // For MVP, just log
                    }) {
                        Text("Browse more prompts")
                            .underline()
                    }
                    .accessibilityLabel("Browse more prompts")
                    // Recent Stories header
                    HStack {
                        Text("Recent Stories")
                            .font(.headline)
                        Spacer()
                        Button(action: { print("[DEBUG] View All tapped") }) {
                            Text("View All")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    // Static recent stories list
                    VStack(spacing: 12) {
                        ForEach(recentStories, id: \.title) { story in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(story.title)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    HStack(spacing: 12) {
                                        Text(story.date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(story.duration)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        if story.shared {
                                            HStack(spacing: 2) {
                                                Image(systemName: "arrowshape.turn.up.right.fill")
                                                    .font(.caption2)
                                                    .foregroundColor(.green)
                                                Text("Shared")
                                                    .font(.caption2)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                                Spacer()
                                Button(action: { print("[DEBUG] Play tapped for \(story.title)") }) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.gray)
                                }
                                .accessibilityLabel("Play \(story.title)")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    // Inactive prompt card (optional)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.blue)
                            Text("Haven't recorded in a while?")
                                .font(.subheadline)
                                .bold()
                        }
                        Text("\"Who inspired you as a child?\"")
                            .font(.body)
                        Button(action: { print("[DEBUG] Record now tapped") }) {
                            Text("Record now")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Home")
            // Present modal when showNewStoryModal is true
            .sheet(isPresented: $showNewStoryModal) {
                NewStoryModalView()
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