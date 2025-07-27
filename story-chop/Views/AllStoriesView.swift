import SwiftUI
import SwiftData

struct AllStoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Story.date, order: .reverse) private var allStories: [Story]
    @State private var selectedStory: Story? = nil
    @State private var showStoryDetail = false
    
    var body: some View {
        NavigationView {
            VStack {
                if allStories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "waveform")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No stories yet")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("Record your first story to see it here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(allStories) { story in
                        Button(action: {
                            print("[DEBUG] Story tapped: \(story.title)")
                            print("[DEBUG] Story data - title: \(story.title), prompt: \(story.prompt), duration: \(story.duration)")
                            selectedStory = story
                            showStoryDetail = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(story.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(story.prompt)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
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
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Story: \(story.title), recorded on \(story.date, style: .date)")
                    }
                }
            }
            .navigationTitle("All Stories")
            .sheet(isPresented: $showStoryDetail) {
                if let story = selectedStory {
                    StoryDetailModal(story: story)
                }
            }
            .onChange(of: showStoryDetail) { oldValue, newValue in
                if newValue {
                    if let story = selectedStory {
                        print("[DEBUG] Presenting StoryDetailModal for story: \(story.title)")
                    } else {
                        print("[DEBUG] ERROR: selectedStory is nil when presenting modal")
                    }
                }
            }
        }
        .onAppear {
            print("[DEBUG] AllStoriesView appeared with \(allStories.count) stories")
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d min", minutes, seconds)
    }
}

#Preview {
    AllStoriesView()
} 