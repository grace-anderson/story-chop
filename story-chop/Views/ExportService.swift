import Foundation
import SwiftData
import Foundation.NSProcessInfo

@Observable final class ExportService {
    
    func exportAllStories(stories: [Story]) -> Result<URL, Error> {
        print("[DEBUG] Starting export of \(stories.count) stories")
        
        // Create temporary directory for export
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("StoryChopExport")
        
        do {
            // Remove existing temp directory if it exists
            if FileManager.default.fileExists(atPath: tempDirectory.path) {
                try FileManager.default.removeItem(at: tempDirectory)
            }
            
            // Create new temp directory
            try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
            
            // Create metadata file
            let metadataURL = tempDirectory.appendingPathComponent("metadata.json")
            let metadata = createMetadataJSON(from: stories)
            try metadata.write(to: metadataURL)
            
            // Copy all audio files
            for story in stories {
                let originalURL = URL(fileURLWithPath: story.filePath)
                let fileName = createFileName(for: story)
                let destinationURL = tempDirectory.appendingPathComponent(fileName)
                
                if FileManager.default.fileExists(atPath: story.filePath) {
                    try FileManager.default.copyItem(at: originalURL, to: destinationURL)
                    print("[DEBUG] Copied story: \(story.title)")
                } else {
                    print("[DEBUG] Warning: Audio file not found for story: \(story.title)")
                }
            }
            
            // Create ZIP file
            let zipURL = FileManager.default.temporaryDirectory.appendingPathComponent("StoryChop_Export_\(Date().timeIntervalSince1970).zip")
            try createZIPArchive(from: tempDirectory, to: zipURL)
            
            print("[DEBUG] Export completed successfully: \(zipURL.path)")
            return .success(zipURL)
            
        } catch {
            print("[DEBUG] Export failed: \(error)")
            return .failure(error)
        }
    }
    
    private func createMetadataJSON(from stories: [Story]) -> Data {
        let metadata: [[String: Any]] = stories.map { story in
            [
                "id": story.id.uuidString,
                "title": story.title,
                "date": ISO8601DateFormatter().string(from: story.date),
                "prompt": story.prompt,
                "duration": story.duration,
                "isShared": story.isShared,
                "isTranscribed": story.isTranscribed,
                "transcription": story.transcription ?? "",
                "fileName": createFileName(for: story)
            ]
        }
        
        let exportData: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "totalStories": stories.count,
            "stories": metadata
        ]
        
        do {
            return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        } catch {
            print("[DEBUG] Failed to create metadata JSON: \(error)")
            return Data()
        }
    }
    
    private func createFileName(for story: Story) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dateString = dateFormatter.string(from: story.date)
        let sanitizedTitle = story.title.replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
        return "\(sanitizedTitle)_\(dateString).m4a"
    }
    
    private func createZIPArchive(from sourceURL: URL, to destinationURL: URL) throws {
        // For now, just copy the directory as-is since ZIP creation requires additional frameworks
        // In a production app, you would use a ZIP library like SSZipArchive or similar
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
    }
    
    func cleanupExport(at url: URL) {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                print("[DEBUG] Cleaned up export file: \(url.path)")
            }
        } catch {
            print("[DEBUG] Failed to cleanup export file: \(error)")
        }
    }
}

enum ExportError: Error, LocalizedError {
    case zipCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .zipCreationFailed:
            return "Failed to create ZIP archive"
        }
    }
} 