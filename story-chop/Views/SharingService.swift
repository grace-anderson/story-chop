import Foundation
import UIKit

@Observable final class SharingService {
    
    func prepareStoryForSharing(story: Story) -> Result<[Any], Error> {
        print("[DEBUG] Preparing story for sharing: \(story.title)")
        
        // Check if original file exists
        guard FileManager.default.fileExists(atPath: story.filePath) else {
            print("[DEBUG] Original audio file not found at path: \(story.filePath)")
            return .failure(SharingError.audioFileNotFound)
        }
        
        // Create a copy with metadata in the name
        let originalURL = URL(fileURLWithPath: story.filePath)
        let fileName = createFileName(for: story)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sharedFileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            // Copy the file to documents directory with new name
            try FileManager.default.copyItem(at: originalURL, to: sharedFileURL)
            print("[DEBUG] Audio file copied to: \(sharedFileURL.path)")
            
            // Create share items: audio file and story title
            var shareItems: [Any] = [sharedFileURL]
            
            // Add story title as text
            let storyInfo = "Story: \(story.title)\nRecorded: \(formatDate(story.date))"
            shareItems.append(storyInfo)
            
            print("[DEBUG] Share items prepared successfully")
            return .success(shareItems)
            
        } catch {
            print("[DEBUG] Error copying audio file: \(error)")
            return .failure(SharingError.fileCopyFailed(error))
        }
    }
    
    private func createFileName(for story: Story) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dateString = dateFormatter.string(from: story.date)
        
        // Clean the title for use in filename (remove special characters)
        let cleanTitle = story.title
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: "*", with: "-")
            .replacingOccurrences(of: "?", with: "-")
            .replacingOccurrences(of: "\"", with: "-")
            .replacingOccurrences(of: "<", with: "-")
            .replacingOccurrences(of: ">", with: "-")
            .replacingOccurrences(of: "|", with: "-")
        
        return "\(cleanTitle)_\(dateString).m4a"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func cleanupSharedFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("[DEBUG] Cleaned up shared file: \(url.path)")
        } catch {
            print("[DEBUG] Error cleaning up shared file: \(error)")
        }
    }
}

// Custom error types for sharing
enum SharingError: LocalizedError {
    case audioFileNotFound
    case fileCopyFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .audioFileNotFound:
            return "Audio file not found"
        case .fileCopyFailed(let error):
            return "Failed to copy audio file: \(error.localizedDescription)"
        }
    }
} 