import SwiftUI
import SwiftData

// MARK: - PromptsView
struct PromptsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Prompt.text) private var allPrompts: [Prompt]
    @Query(sort: \PromptCategory.name) private var categories: [PromptCategory]
    
    // Browse prompts state
    @State private var showPromptSelectionModal = false
    @State private var showConfirmationDialog = false
    @State private var selectedPromptForConfirmation: String = ""
    
    // Add prompt modal state
    @State private var showAddPromptModal = false
    
    // Navigation state
    @Binding var selectedTab: Int
    
    // Seeding state
    @State private var didSeed: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Browse prompts section (moved to top)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Browse prompts")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Explore prompts and choose one you love. Tap it to make it your home page prompt.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        Button(action: {
                            print("[DEBUG] Browse prompts tapped")
                            showPromptSelectionModal = true
                        }) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .font(.system(size: 16))
                                Text("Browse all prompts by category")
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                        .accessibilityLabel("Browse all prompts by category")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    
                    // Add a prompt section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add a prompt")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            print("[DEBUG] Add a prompt tapped")
                            showAddPromptModal = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16))
                                Text("Add a prompt")
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(12)
                        }
                        .accessibilityLabel("Add a prompt")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)

                    // Recently added prompts section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recently added prompts")
                            .font(.headline)
                            .fontWeight(.bold)

                        if let recentPrompts = getRecentPrompts(), !recentPrompts.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(recentPrompts, id: \.id) { prompt in
                                    Button(action: {
                                        print("[DEBUG] Recent prompt tapped: \(prompt.text)")
                                        selectedPromptForConfirmation = prompt.text
                                        showConfirmationDialog = true
                                    }) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(prompt.text)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            HStack {
                                                Text(prompt.category)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.blue.opacity(0.1))
                                                    .cornerRadius(6)
                                                
                                                Spacer()
                                                
                                                Text(formatDate(prompt.dateAdded))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding()
                                        .background(Color(.systemBackground))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(.systemGray4), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .accessibilityLabel("Select prompt: \(prompt.text)")
                                }
                            }
                        } else {
                            Text("Add a prompt to see it here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Prompts")
        }
        .onAppear {
            print("[DEBUG] PromptsView appeared. allPrompts count: \(allPrompts.count)")
            if allPrompts.isEmpty {
                seedPromptsIfNeeded()
            }
        }
        .sheet(isPresented: $showPromptSelectionModal) {
            PromptSelectionModal(
                onDismiss: {
                    showPromptSelectionModal = false
                },
                onPromptSelected: { prompt in
                    print("[DEBUG] Prompt selected from browse: \(prompt)")
                    selectedPromptForConfirmation = prompt
                    showConfirmationDialog = true
                    showPromptSelectionModal = false
                }
            )
        }
        .sheet(isPresented: $showAddPromptModal) {
            AddPromptModal(
                onDismiss: {
                    showAddPromptModal = false
                },
                onPromptAdded: {
                    print("[DEBUG] Prompt added, refreshing daily prompt service cache")
                    // Refresh the daily prompt service cache to include new prompts
                    // This will be handled by the HomeView when it appears
                }
            )
        }
        .alert("Set Selected Prompt", isPresented: $showConfirmationDialog) {
            Button("Yes") {
                print("[DEBUG] User confirmed prompt selection: \(selectedPromptForConfirmation)")
                // Update Home screen's selected prompt
                updateHomeScreenPrompt(selectedPromptForConfirmation)
                // Navigate to Home tab
                selectedTab = 0
            }
            Button("No", role: .cancel) {
                print("[DEBUG] User cancelled prompt selection")
                selectedPromptForConfirmation = ""
            }
        } message: {
            Text("Set '\(selectedPromptForConfirmation)' as your selected prompt?")
        }
    }
    
    // Helper to seed prompts and categories from .md file
    private func seedPromptsIfNeeded() {
        guard !didSeed, allPrompts.isEmpty else { return }
        print("[DEBUG] Seeding prompts from storychop_prompts.md into SwiftData")
        let promptData = PromptsView.seedPromptsData()
        for cat in promptData.categories {
            let newCat = PromptCategory(name: cat.name)
            modelContext.insert(newCat)
        }
        for prompt in promptData.prompts {
            let newPrompt = Prompt(text: prompt.text, category: prompt.category, isUserCreated: false, dateAdded: nil)
            modelContext.insert(newPrompt)
        }
        try? modelContext.save()
        didSeed = true
    }
    
    private func updateHomeScreenPrompt(_ prompt: String) {
        // Update the shared selected prompt manager
        SelectedPromptManager.shared.setSelectedPrompt(prompt)
        print("[DEBUG] Updated Home screen prompt to: \(prompt)")
    }
    
    static func seedPromptsData() -> (prompts: [Prompt], categories: [PromptCategory]) {
        let raw = """
## Childhood & Family

- What is your earliest memory?
- What games did you love to play as a child?
- Who were your childhood friends?
- What was your favourite toy or game?
- What did your family do for fun when you were growing up?
- Describe the home you grew up in.
- What was your relationship like with your siblings?
- What chores or responsibilities did you have as a child?
- What holidays or traditions did your family celebrate?
- What meals remind you of your childhood?

## School Days

- What was your first day of school like?
- Who was your favourite teacher, and why?
- What subject did you enjoy the most? The least?
- Did you ever get in trouble at school?
- What school events or activities do you remember most?
- How did you get to school each day?
- Did you have a childhood nickname?
- What were your dreams or goals as a teenager?
- Did you go to a school dance or social event?
- What was your first job?

## Love & Relationships

- How did you meet your partner?
- What was your first date like?
- What advice would you give about love?
- How did you know they were "the one"?
- Describe your wedding day.
- What was your first big argument as a couple?
- What do you admire most about your partner?
- What did you learn from past relationships?
- How has your understanding of love changed over time?
- What's your secret to a long-lasting relationship?

## Raising a Family

- How did you feel when you became a parent?
- What was the most surprising thing about raising children?
- What family traditions did you start?
- What advice would you give to new parents?
- What did your children teach you?
- Describe a proud parenting moment.
- What did a typical day look like when your children were young?
- How did you balance work and family life?
- What challenges did your family face together?
- How has your role in the family changed over time?

## Home Life & Routines

- What was your first home like?
- What's your favourite room in the house, and why?
- Describe a typical Sunday when your kids were young.
- What kind of meals did you cook regularly?
- What does "home" mean to you?
- Have you ever renovated or built a home?
- How did your home reflect your personality or values?
- Do you remember any family pets?
- What were some rules in your household growing up?
- What home smells or sounds bring back memories?

## Work & Career

- What was your very first job?
- What job did you enjoy the most, and why?
- Who influenced your work ethic?
- Did you ever change careers?
- What were your biggest work challenges?
- Describe a day at work that stands out.
- What did you learn from your co-workers?
- Were you ever a mentor or role model at work?
- What advice would you give to someone entering your field?
- What did retirement feel like?

## Travel & Adventure

- What was your first big trip?
- What's your favourite travel memory?
- Did you ever get lost or have a funny travel mishap?
- Where did you go on family holidays?
- If you could go anywhere again, where would it be?
- What place surprised you the most?
- Did you ever travel for work?
- Have you ever travelled alone?
- What country or culture fascinated you?
- What did you learn from your travels?

## Life Lessons & Reflections

- What's the best advice you've ever received?
- What have you learned about forgiveness?
- How have your priorities changed over time?
- What does happiness mean to you now?
- What's something you used to worry about that doesn't matter anymore?
- What life lesson took you the longest to learn?
- What's something you're proud of that others might not know about?
- How do you define success?
- What would you tell your younger self?
- How do you want to be remembered?

## Milestones & Celebrations

- What birthdays do you remember best?
- How did you celebrate major anniversaries?
- What's a moment when you felt truly celebrated?
- Did you ever throw or attend a surprise party?
- How did you celebrate your children's milestones?
- What was a meaningful retirement celebration?
- What traditions did you create for special occasions?
- What did holidays look like in your family?
- Did you ever host a big family gathering?
- Describe a moment that felt like a personal triumph.

## Hobbies, Passions & Everyday Joys

- What hobbies have you loved over the years?
- What's something you've made with your hands?
- What music takes you back in time?
- What's a book or film that changed how you see the world?
- What simple pleasures bring you the most joy?
- Did you ever collect anything?
- What was a favourite way to spend a quiet afternoon?
- Have you ever performed on stage or in front of others?
- What was your favourite way to spend time with friends?
- If you had one more day to relive, what would it be?

## Friends & Social Life

- Who was your first best friend, and how did you meet?
- What mischief or adventures did you get up to with friends?
- Who is a friend that had a lasting impact on your life?
- How did you stay in touch with friends over the years?
- What role did friends play during difficult times?
- Have you ever lost touch with a friend and reconnected later?
- What qualities do you value most in a friend?
- What's a funny or memorable story involving your friends?
- How have your friendships changed as you've grown older?
- What does friendship mean to you today?
"""
        var prompts: [Prompt] = []
        var categories: [PromptCategory] = []
        var currentCategory = ""
        for line in raw.components(separatedBy: "\n") {
            if line.hasPrefix("## ") {
                currentCategory = line.replacingOccurrences(of: "## ", with: "").trimmingCharacters(in: .whitespaces)
                if !categories.contains(where: { $0.name == currentCategory }) {
                    categories.append(PromptCategory(name: currentCategory))
                }
            } else if line.hasPrefix("- ") {
                let promptText = line.replacingOccurrences(of: "- ", with: "").trimmingCharacters(in: .whitespaces)
                if !promptText.isEmpty && !currentCategory.isEmpty {
                    prompts.append(Prompt(text: promptText, category: currentCategory, isUserCreated: false))
                }
            }
        }
        return (prompts, categories)
    }
    
    // Helper function to get the 5 most recently added prompts
    private func getRecentPrompts() -> [Prompt]? {
        print("[DEBUG] Getting recent prompts")
        
        // Filter for user-created prompts with dateAdded, sorted by most recent first
        let userPrompts = allPrompts.filter { $0.isUserCreated && $0.dateAdded != nil }
        
        if userPrompts.isEmpty {
            print("[DEBUG] No user-created prompts found")
            return nil
        }
        
        // Sort by dateAdded (most recent first) and take first 5
        let sortedPrompts = userPrompts.sorted { 
            guard let date1 = $0.dateAdded, let date2 = $1.dateAdded else { return false }
            return date1 > date2 
        }
        
        let recentPrompts = Array(sortedPrompts.prefix(5))
        print("[DEBUG] Found \(recentPrompts.count) recent prompts")
        return recentPrompts
    }
    
    // Helper function to format the date for display
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown date" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
}

#Preview {
    PromptsView(selectedTab: .constant(1))
} 