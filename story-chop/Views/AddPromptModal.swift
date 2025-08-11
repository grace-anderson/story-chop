import SwiftUI
import SwiftData

struct AddPromptModal: View {
    let onDismiss: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PromptCategory.name) private var categories: [PromptCategory]
    
    // Add prompt section state
    @State private var newPromptText: String = ""
    @State private var selectedCategory: String = ""
    @State private var newCategoryText: String = ""
    @State private var validationMessage: String? = nil
    @State private var showSuccessAlert: Bool = false
    
    // Category selection mode
    @State private var categorySelectionMode: CategorySelectionMode = .existing
    
    enum CategorySelectionMode {
        case existing
        case new
    }
    
    // Character limits
    private let maxCategoryCharacters = 60
    private let maxPromptCharacters = 200
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Add your own prompt section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add your own prompt")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        // Prompt text field with character counter
                        VStack(alignment: .leading, spacing: 4) {
                            TextEditor(text: $newPromptText)
                                .frame(minHeight: 80)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                .overlay(
                                    Group {
                                        if newPromptText.isEmpty {
                                            Text("Enter your prompt")
                                                .foregroundColor(.secondary)
                                                .padding(.leading, 12)
                                                .padding(.top, 12)
                                        }
                                    }
                                    , alignment: .topLeading
                                )
                                .accessibilityLabel("Enter your prompt")
                            
                            HStack {
                                Spacer()
                                Text("\(newPromptText.count)/\(maxPromptCharacters)")
                                    .font(.caption)
                                    .foregroundColor(newPromptText.count > maxPromptCharacters ? .red : .secondary)
                            }
                        }
                        
                        // Category selection with toggle
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            // Toggle buttons
                            HStack(spacing: 12) {
                                Button(action: {
                                    categorySelectionMode = .existing
                                    newCategoryText = ""
                                }) {
                                    HStack {
                                        Image(systemName: categorySelectionMode == .existing ? "checkmark.circle.fill" : "circle")
                                        Text("Select existing category")
                                    }
                                    .foregroundColor(categorySelectionMode == .existing ? .blue : .primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(categorySelectionMode == .existing ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    categorySelectionMode = .new
                                    selectedCategory = ""
                                }) {
                                    HStack {
                                        Image(systemName: categorySelectionMode == .new ? "checkmark.circle.fill" : "circle")
                                        Text("Create new category")
                                    }
                                    .foregroundColor(categorySelectionMode == .new ? .blue : .primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(categorySelectionMode == .new ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Category input based on selection mode
                            if categorySelectionMode == .existing {
                                Picker("Select category", selection: $selectedCategory) {
                                    Text("Select category").tag("")
                                    ForEach(categories, id: \.name) { cat in
                                        Text(cat.name).tag(cat.name)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accessibilityLabel("Select category")
                            } else {
                                VStack(alignment: .leading, spacing: 4) {
                                    TextEditor(text: $newCategoryText)
                                        .frame(minHeight: 60)
                                        .padding(8)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(.systemGray4), lineWidth: 1)
                                        )
                                        .overlay(
                                            Group {
                                                if newCategoryText.isEmpty {
                                                    Text("Enter new category name")
                                                        .foregroundColor(.secondary)
                                                        .padding(.leading, 12)
                                                        .padding(.top, 12)
                                                }
                                            }
                                            , alignment: .topLeading
                                        )
                                        .accessibilityLabel("Enter new category name")
                                    
                                    HStack {
                                        Spacer()
                                        Text("\(newCategoryText.count)/\(maxCategoryCharacters)")
                                            .font(.caption)
                                            .foregroundColor(newCategoryText.count > maxCategoryCharacters ? .red : .secondary)
                                    }
                                }
                            }
                        }
                        
                        // Add button
                        Button(action: {
                            addPrompt()
                        }) {
                            Text("Add Prompt")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isAddButtonEnabled ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(!isAddButtonEnabled)
                        .accessibilityLabel("Add prompt")
                        
                        // Validation message
                        if let message = validationMessage {
                            Text(message)
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Prompt")
            .navigationBarTitleDisplayMode(.inline)
                                    .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    print("[DEBUG] AddPromptModal cancelled - discarding changes")
                                    // Reset form and dismiss
                                    resetForm()
                                    onDismiss()
                                }
                            }
                        }
        }
        .onAppear {
            print("[DEBUG] AddPromptModal appeared")
        }
        .alert("Prompt added", isPresented: $showSuccessAlert) {
            Button("Add another prompt") {
                print("[DEBUG] User chose to add another prompt")
                resetForm()
            }
            Button("Return to Prompt home") {
                print("[DEBUG] User chose to return to Prompt home")
                onDismiss()
            }
        } message: {
            Text("Your prompt has been successfully added. Would you like to add another prompt or return to the main prompts screen?")
        }
    }
    
    // Computed property for add button state
    private var isAddButtonEnabled: Bool {
        let trimmedPrompt = newPromptText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = categorySelectionMode == .existing ? 
            selectedCategory : 
            newCategoryText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !trimmedPrompt.isEmpty && 
               !trimmedCategory.isEmpty && 
               trimmedPrompt.count <= maxPromptCharacters &&
               (categorySelectionMode == .existing || trimmedCategory.count <= maxCategoryCharacters)
    }
    
    private func addPrompt() {
        validationMessage = nil
        let trimmedPrompt = newPromptText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = categorySelectionMode == .existing ? 
            selectedCategory : 
            newCategoryText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation
        if trimmedPrompt.isEmpty {
            validationMessage = "Please enter a prompt."
            return
        }
        if trimmedCategory.isEmpty {
            validationMessage = "Please select or enter a category."
            return
        }
        if trimmedPrompt.count > maxPromptCharacters {
            validationMessage = "Prompt must be \(maxPromptCharacters) characters or less."
            return
        }
        if categorySelectionMode == .new && trimmedCategory.count > maxCategoryCharacters {
            validationMessage = "Category must be \(maxCategoryCharacters) characters or less."
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
        
        do {
            try modelContext.save()
            print("[DEBUG] Added new prompt: \(trimmedPrompt) in category: \(trimmedCategory)")
            
                                    // Show success alert
                        showSuccessAlert = true
            
        } catch {
            print("[DEBUG] Error saving prompt: \(error)")
            validationMessage = "Failed to save prompt. Please try again."
        }
    }
    
    private func resetFormFields() {
        newPromptText = ""
        newCategoryText = ""
        selectedCategory = ""
        categorySelectionMode = .existing
    }
    
    private func resetForm() {
        print("[DEBUG] Resetting AddPromptModal form")
        resetFormFields()
        validationMessage = nil
        showSuccessAlert = false
    }
}

#Preview {
    AddPromptModal(onDismiss: {})
}
