import SwiftUI
import SwiftData

struct HomeView: View {
    // Binding to control modal presentation from parent
    @Binding var showNewStoryModal: Bool
    // Binding to control tab selection
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Story.date, order: .reverse) private var allStories: [Story]
    @State private var selectedStory: Story? = nil
    @State private var showStoryDetail = false
    
    // Get 5 most recent stories
    var recentStories: [Story] {
        Array(allStories.prefix(5))
    }
    
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
                        print("[DEBUG] Browse more prompts tapped - navigating to Prompts tab")
                        selectedTab = 1 // Switch to Prompts tab (tag 1)
                    }) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                            Text("Browse more prompts")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.orange.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .accessibilityLabel("Browse more prompts")
                    // Recent Stories header
                    HStack {
                        Text("Recent Stories")
                            .font(.headline)
                        Spacer()
                        Button(action: { 
                            print("[DEBUG] View All tapped - navigating to All Stories tab")
                            selectedTab = 2 // Switch to All Stories tab (tag 2)
                        }) {
                            Text("View All")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    // Dynamic recent stories list from SwiftData
                    if recentStories.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "waveform")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No stories yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Record your first story to see it here")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(recentStories) { story in
                                Button(action: {
                                    print("[DEBUG] Recent story tapped: \(story.title)")
                                    selectedStory = story
                                    showStoryDetail = true
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(story.title)
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            HStack(spacing: 12) {
                                                Text(story.date, style: .date)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Text(formatDuration(story.duration))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                if story.isShared {
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
                                        Button(action: { 
                                            print("[DEBUG] Play tapped for \(story.title)")
                                            selectedStory = story
                                            showStoryDetail = true
                                        }) {
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
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                }
                .padding()
            }
            .navigationTitle("Home")
            // Present modal when showNewStoryModal is true
            .sheet(isPresented: $showNewStoryModal) {
                NewStoryModalView()
            }
            // Present story detail modal
            .sheet(isPresented: $showStoryDetail) {
                if let story = selectedStory {
                    StoryDetailModal(story: story)
                }
            }
        }
        .onAppear {
            print("[DEBUG] HomeView appeared with \(allStories.count) total stories")
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d min", minutes, seconds)
    }
}

#Preview {
    // Use a constant binding for preview
    HomeView(showNewStoryModal: .constant(false), selectedTab: .constant(0))
} 
