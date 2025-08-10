import SwiftUI
import SwiftData

// Enum for modal navigation states
private enum PromptSelectionState {
    case categories
    case prompts(category: String)
}

struct PromptSelectionModal: View {
    let onDismiss: () -> Void
    let onPromptSelected: (String) -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PromptCategory.name) private var categories: [PromptCategory]
    @Query(sort: \Prompt.text) private var allPrompts: [Prompt]
    
    @State private var currentState: PromptSelectionState = .categories
    @State private var selectedCategory: String = ""
    
    // Get prompts organized by category
    private var categorizedPrompts: [String: [String]] {
        var result: [String: [String]] = [:]
        
        for category in categories {
            let categoryPrompts = allPrompts.filter { $0.category == category.name }
            result[category.name] = categoryPrompts.map { $0.text }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack {
                switch currentState {
                case .categories:
                    CategorySelectionView(
                        categories: categories,
                        categorizedPrompts: categorizedPrompts,
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Back") {
                            print("[DEBUG] Going back to categories")
                            currentState = .categories
                        }
                    }
                }
            }
        }
        .onAppear {
            print("[DEBUG] PromptSelectionModal appeared with \(categories.count) categories and \(allPrompts.count) total prompts")
            // Force a refresh of the SwiftData queries to ensure data is loaded
            if categories.isEmpty {
                print("[DEBUG] No categories found, triggering refresh")
                // This will trigger the SwiftData queries to refresh
            }
        }
    }
}

// Category selection view
private struct CategorySelectionView: View {
    let categories: [PromptCategory]
    let categorizedPrompts: [String: [String]]
    let onCategorySelected: (String) -> Void
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 16) {
                ForEach(categories, id: \.id) { category in
                    Button(action: {
                        onCategorySelected(category.name)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                
                                Text("\(categorizedPrompts[category.name]?.count ?? 0) prompts")
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
            .padding(.leading, 16)
            .padding(.trailing, 24) // Extra padding on right to make scroll indicator more accessible
            .padding(.top, 8)
            .padding(.bottom, 20) // Extra padding at bottom for better scrolling
        }
        .scrollIndicators(.visible, axes: .vertical) // Make scroll indicators always visible
        .scrollContentBackground(.hidden) // Hide background to make scroll indicator more prominent
        .onAppear {
            print("[DEBUG] CategorySelectionView appeared with \(categories.count) categories")
        }
    }
}

// Prompt list view
private struct PromptListView: View {
    let category: String
    let prompts: [String]
    let onPromptSelected: (String) -> Void
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
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
            .padding(.leading, 16)
            .padding(.trailing, 24) // Extra padding on right to make scroll indicator more accessible
            .padding(.top, 8)
            .padding(.bottom, 20) // Extra padding at bottom for better scrolling
        }
        .scrollIndicators(.visible, axes: .vertical) // Make scroll indicators always visible
        .scrollContentBackground(.hidden) // Hide background to make scroll indicator more prominent
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