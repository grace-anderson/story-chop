import SwiftUI

// Enum for modal navigation states
private enum PromptSelectionState {
    case categories
    case prompts(category: String)
}

struct PromptSelectionModal: View {
    let onDismiss: () -> Void
    let onPromptSelected: (String) -> Void
    
    @State private var currentState: PromptSelectionState = .categories
    @State private var selectedCategory: String = ""
    
    // Organized prompts by category
    private let categorizedPrompts: [String: [String]] = [
        "Family & Home": [
            "Tell us about your first home",
            "Describe a favorite family tradition"
        ],
        "People & Inspiration": [
            "Who inspired you as a child?"
        ],
        "Work & Career": [
            "What was your first job?"
        ],
        "Memories & Experiences": [
            "Share a memorable holiday experience"
        ]
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                switch currentState {
                case .categories:
                    CategorySelectionView(
                        categories: Array(categorizedPrompts.keys.sorted()),
                        onCategorySelected: { category in
                            print("[DEBUG] Category selected: \(category)")
                            selectedCategory = category
                            currentState = .prompts(category: category)
                        }
                    )
                case .prompts(let category):
                    PromptListView(
                        category: category,
                        prompts: categorizedPrompts[category] ?? [],
                        onPromptSelected: { prompt in
                            print("[DEBUG] Prompt selected: \(prompt)")
                            onPromptSelected(prompt)
                            onDismiss()
                        }
                    )
                }
            }
            .navigationTitle("Select a Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        print("[DEBUG] Prompt selection cancelled")
                        onDismiss()
                    }
                }
                
                if case .prompts = currentState {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") {
                            print("[DEBUG] Going back to categories")
                            currentState = .categories
                        }
                    }
                }
            }
        }
        .onAppear {
            print("[DEBUG] PromptSelectionModal appeared")
        }
    }
}

// Category selection view
private struct CategorySelectionView: View {
    let categories: [String]
    let onCategorySelected: (String) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        onCategorySelected(category)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                
                                Text("\(categorizedPrompts[category]?.count ?? 0) prompts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .onAppear {
            print("[DEBUG] CategorySelectionView appeared with \(categories.count) categories")
        }
    }
    
    // Helper to get prompt count for each category
    private var categorizedPrompts: [String: [String]] {
        [
            "Family & Home": [
                "Tell us about your first home",
                "Describe a favorite family tradition"
            ],
            "People & Inspiration": [
                "Who inspired you as a child?"
            ],
            "Work & Career": [
                "What was your first job?"
            ],
            "Memories & Experiences": [
                "Share a memorable holiday experience"
            ]
        ]
    }
}

// Prompt list view
private struct PromptListView: View {
    let category: String
    let prompts: [String]
    let onPromptSelected: (String) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(prompts, id: \.self) { prompt in
                    Button(action: {
                        onPromptSelected(prompt)
                    }) {
                        HStack {
                            Text(prompt)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.blue)
                                .opacity(0)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .onAppear {
            print("[DEBUG] PromptListView appeared for category: \(category) with \(prompts.count) prompts")
        }
    }
}

#Preview {
    PromptSelectionModal(
        onDismiss: {},
        onPromptSelected: { _ in }
    )
} 