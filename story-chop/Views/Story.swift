import SwiftUI
import SwiftData

@Model class Story {
    @Attribute(.unique) var id: UUID
    var title: String
    var date: Date
    var prompt: String
    var duration: TimeInterval
    var filePath: String
    var isShared: Bool
    
    init(id: UUID = UUID(), title: String, date: Date = Date(), prompt: String, duration: TimeInterval, filePath: String, isShared: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.prompt = prompt
        self.duration = duration
        self.filePath = filePath
        self.isShared = isShared
        print("[DEBUG] Story created: \(title) with duration: \(duration)s")
    }
} 