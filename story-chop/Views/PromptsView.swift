import SwiftUI
import SwiftData

// MARK: - PromptsView
struct PromptsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Prompt.text) private var allPrompts: [Prompt]
    @Query(sort: \PromptCategory.name) private var categories: [PromptCategory]
    @State private var displayedPrompts: [Prompt] = []
    @State private var newPromptText: String = ""
    @State private var selectedCategory: String = ""
    @State private var newCategoryText: String = ""
    @State private var validationMessage: String? = nil
    @State private var didSeed: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Refresh button
                Button(action: {
                    refreshDisplayedPrompts()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh prompts")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .accessibilityLabel("Refresh prompts")
                // Prompts list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(displayedPrompts) { prompt in
                            HStack(alignment: .center, spacing: 8) {
                                Text(prompt.text)
                                    .font(.title3)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(14)
                                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 2)
                                    .accessibilityLabel("Prompt: \(prompt.text)")
                                // Show 'Just Added' badge if within 24 hours
                                if let date = prompt.dateAdded, Date().timeIntervalSince(date) < 60*60*24 {
                                    Label("Just Added", systemImage: "clock.fill")
                                        .font(.caption)
                                        .padding(6)
                                        .background(Color.green.opacity(0.85))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .accessibilityLabel("Just added prompt")
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                // Add prompt section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add your own prompt")
                        .font(.headline)
                    TextField("Enter your prompt", text: $newPromptText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityLabel("Enter your prompt")
                    HStack {
                        Picker("Category", selection: $selectedCategory) {
                            Text("Select category").tag("")
                            ForEach(categories, id: \.name) { cat in
                                Text(cat.name).tag(cat.name)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accessibilityLabel("Select category")
                        Text("or")
                        TextField("New category", text: $newCategoryText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .accessibilityLabel("Enter new category")
                    }
                    Button(action: {
                        addPrompt()
                    }) {
                        Text("Add Prompt")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(newPromptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (selectedCategory.isEmpty && newCategoryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                    .accessibilityLabel("Add prompt")
                    if let message = validationMessage {
                        Text(message)
                            .foregroundColor(message == "Prompt added!" ? .green : .red)
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(14)
                Spacer()
            }
            .padding()
            .navigationTitle("Prompts")
        }
        .onAppear {
            print("[DEBUG] PromptsView appeared. allPrompts count: \(allPrompts.count)")
            if allPrompts.isEmpty {
                seedPromptsIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    refreshDisplayedPrompts()
                }
            } else {
                refreshDisplayedPrompts()
            }
        }
        .onChange(of: allPrompts) { oldValue, newValue in
            print("[DEBUG] allPrompts changed. New count: \(newValue.count)")
            refreshDisplayedPrompts()
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
    private func refreshDisplayedPrompts() {
        print("[DEBUG] Refreshing displayed prompts from SwiftData")
        // Find all 'just added' prompts (user created, within 24 hours)
        let justAdded = allPrompts.filter { $0.isUserCreated && $0.dateAdded != nil && Date().timeIntervalSince($0.dateAdded!) < 60*60*24 }
        // Get the rest, excluding 'just added'
        let rest = allPrompts.filter { !(justAdded.contains($0)) }
        // Shuffle the rest and take up to (10 - justAdded.count)
        let randomRest = Array(rest.shuffled().prefix(max(0, 10 - justAdded.count)))
        // Combine, with 'just added' always at the top
        displayedPrompts = justAdded + randomRest
        print("[DEBUG] displayedPrompts after refresh: \(displayedPrompts.map { $0.text })")
    }
    private func addPrompt() {
        validationMessage = nil
        let trimmedPrompt = newPromptText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = selectedCategory.isEmpty ? newCategoryText.trimmingCharacters(in: .whitespacesAndNewlines) : selectedCategory
        if trimmedPrompt.isEmpty {
            validationMessage = "Please enter a prompt."
            return
        }
        if trimmedCategory.isEmpty {
            validationMessage = "Please select or enter a category."
            return
        }
        // Add category if new
        var catToUse: PromptCategory? = categories.first(where: { $0.name == trimmedCategory })
        if catToUse == nil {
            let newCat = PromptCategory(name: trimmedCategory)
            modelContext.insert(newCat)
            catToUse = newCat
        }
        let newPrompt = Prompt(text: trimmedPrompt, category: trimmedCategory, isUserCreated: true, dateAdded: Date())
        modelContext.insert(newPrompt)
        try? modelContext.save()
        newPromptText = ""
        newCategoryText = ""
        selectedCategory = ""
        // Always refresh to put new prompt at the top
        refreshDisplayedPrompts()
        validationMessage = "Prompt added!"
        print("[DEBUG] Added new prompt: \(trimmedPrompt) in category: \(trimmedCategory) at \(String(describing: newPrompt.dateAdded))")
        print("[DEBUG] displayedPrompts after add: \(displayedPrompts.map { $0.text })")
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
- How did you know they were “the one”?
- Describe your wedding day.
- What was your first big argument as a couple?
- What do you admire most about your partner?
- What did you learn from past relationships?
- How has your understanding of love changed over time?
- What’s your secret to a long-lasting relationship?

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
- What’s your favourite room in the house, and why?
- Describe a typical Sunday when your kids were young.
- What kind of meals did you cook regularly?
- What does “home” mean to you?
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
- What’s your favourite travel memory?
- Did you ever get lost or have a funny travel mishap?
- Where did you go on family holidays?
- If you could go anywhere again, where would it be?
- What place surprised you the most?
- Did you ever travel for work?
- Have you ever travelled alone?
- What country or culture fascinated you?
- What did you learn from your travels?

## Life Lessons & Reflections

- What’s the best advice you’ve ever received?
- What have you learned about forgiveness?
- How have your priorities changed over time?
- What does happiness mean to you now?
- What’s something you used to worry about that doesn’t matter anymore?
- What life lesson took you the longest to learn?
- What’s something you’re proud of that others might not know about?
- How do you define success?
- What would you tell your younger self?
- How do you want to be remembered?

## Milestones & Celebrations

- What birthdays do you remember best?
- How did you celebrate major anniversaries?
- What’s a moment when you felt truly celebrated?
- Did you ever throw or attend a surprise party?
- How did you celebrate your children’s milestones?
- What was a meaningful retirement celebration?
- What traditions did you create for special occasions?
- What did holidays look like in your family?
- Did you ever host a big family gathering?
- Describe a moment that felt like a personal triumph.

## Hobbies, Passions & Everyday Joys

- What hobbies have you loved over the years?
- What’s something you’ve made with your hands?
- What music takes you back in time?
- What’s a book or film that changed how you see the world?
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
- What’s a funny or memorable story involving your friends?
- How have your friendships changed as you’ve grown older?
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
}

#Preview {
    PromptsView()
} 