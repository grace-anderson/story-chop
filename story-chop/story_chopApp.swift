//
//  story_chopApp.swift
//  story-chop
//
//  Created by Helen Anderson on 20/7/2025.
//

import SwiftUI
import SwiftData

@main
struct story_chopApp: App {
    // Set up the SwiftData model container with validation
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Prompt.self,
            PromptCategory.self,
            Story.self
        ])
        
        // Add database validation and recreation logic
        do {
            let container = try ModelContainer(for: schema)
            print("[DEBUG] SwiftData container created successfully with schema: \(schema)")
            
            // Validate that all required tables exist
            validateDatabaseTables(container)
            
            return container
        } catch {
            print("[DEBUG] Error creating ModelContainer: \(error)")
            
            // If creation fails, try to delete corrupted database and recreate
            if let container = recreateDatabaseWithSchema(schema) {
                return container
            }
            
            // Final fallback - create with force recreation
            print("[DEBUG] Attempting final fallback database creation")
            return try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
    
    // MARK: - Database Validation and Recovery
    
    /// Validates that all required database tables exist
    private static func validateDatabaseTables(_ container: ModelContainer) {
        print("[DEBUG] Validating database tables...")
        
        do {
            let context = container.mainContext
            
            // Test each model type to ensure tables exist
            let promptCount = try context.fetch(FetchDescriptor<Prompt>()).count
            let categoryCount = try context.fetch(FetchDescriptor<PromptCategory>()).count
            let storyCount = try context.fetch(FetchDescriptor<Story>()).count
            
            print("[DEBUG] Database validation successful:")
            print("[DEBUG] - Prompts table: \(promptCount) records")
            print("[DEBUG] - Categories table: \(categoryCount) records") 
            print("[DEBUG] - Stories table: \(storyCount) records")
            
        } catch {
            print("[DEBUG] Database validation failed: \(error)")
            print("[DEBUG] This indicates database corruption - attempting recovery...")
            
            // Trigger database recreation
            if let newContainer = recreateDatabaseWithSchema(container.schema) {
                print("[DEBUG] Database recovery successful")
                // Note: In a real app, you'd want to replace the container reference
                // For now, this will help with the next app launch
            }
        }
    }
    
    /// Attempts to recreate the database by deleting corrupted files and recreating
    private static func recreateDatabaseWithSchema(_ schema: Schema) -> ModelContainer? {
        print("[DEBUG] Attempting database recreation...")
        
        do {
            // Get the database file path
            let container = try ModelContainer(for: schema)
            let storeURL = container.configurations.first?.url
            
            if let storeURL = storeURL {
                print("[DEBUG] Found database at: \(storeURL)")
                
                // Delete the corrupted database files
                try deleteDatabaseFiles(at: storeURL)
                print("[DEBUG] Deleted corrupted database files")
            }
            
            // Create new container with clean database
            let newContainer = try ModelContainer(for: schema)
            print("[DEBUG] Successfully recreated database")
            
            return newContainer
            
        } catch {
            print("[DEBUG] Database recreation failed: \(error)")
            return nil
        }
    }
    
    /// Deletes all database-related files at the given URL
    private static func deleteDatabaseFiles(at url: URL) throws {
        let fileManager = FileManager.default
        let directory = url.deletingLastPathComponent()
        let baseName = url.deletingPathExtension().lastPathComponent
        
        // Delete main database file
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
            print("[DEBUG] Deleted main database file")
        }
        
        // Delete associated files (wal, shm, etc.)
        let associatedExtensions = ["-wal", "-shm", "-journal"]
        for ext in associatedExtensions {
            let associatedFile = directory.appendingPathComponent("\(baseName)\(ext)")
            if fileManager.fileExists(atPath: associatedFile.path) {
                try fileManager.removeItem(at: associatedFile)
                print("[DEBUG] Deleted associated file: \(ext)")
            }
        }
    }
}
