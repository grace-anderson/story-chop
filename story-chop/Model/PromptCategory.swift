import SwiftUI
import SwiftData

@Model class PromptCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
} 