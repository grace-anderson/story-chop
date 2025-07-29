import SwiftUI
import SwiftData

@Model class Prompt {
    @Attribute(.unique) var id: UUID
    var text: String
    var category: String
    var isUserCreated: Bool
    var dateAdded: Date? // New property for 'just added' logic
    
    init(id: UUID = UUID(), text: String, category: String, isUserCreated: Bool = false, dateAdded: Date? = nil) {
        self.id = id
        self.text = text
        self.category = category
        self.isUserCreated = isUserCreated
        self.dateAdded = dateAdded
    }
} 