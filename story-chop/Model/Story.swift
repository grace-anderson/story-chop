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
    var transcription: String? // Store transcribed text
    var isTranscribed: Bool // Track if transcription has been completed
    
    init(id: UUID = UUID(), title: String, date: Date = Date(), prompt: String, duration: TimeInterval, filePath: String, isShared: Bool = false, transcription: String? = nil, isTranscribed: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.prompt = prompt
        self.duration = duration
        self.filePath = filePath
        self.isShared = isShared
        self.transcription = transcription
        self.isTranscribed = isTranscribed
        print("[DEBUG] Story created: \(title) with duration: \(duration)s, isTranscribed: \(isTranscribed)")
    }
} 