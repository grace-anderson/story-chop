import SwiftUI
import SwiftData
import MessageUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stories: [Story]
    
    @State private var exportService = ExportService()
    @State private var showExportSheet = false
    @State private var showPrivacyPolicy = false
    @State private var showExportErrorAlert = false
    @State private var exportErrorMessage = ""
    @State private var exportURL: URL?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Privacy Statement
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your voice is yours. We never share without your permission.")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Button(action: {
                            showPrivacyPolicy = true
                        }) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundColor(.blue)
                                Text("Privacy Policy")
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                        .accessibilityLabel("View privacy policy")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Settings Options
                    VStack(spacing: 0) {
                        // Export All Stories
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            title: "Export All Stories",
                            subtitle: "Download all your stories as a ZIP file",
                            action: exportAllStories
                        )
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // Help & Support
                        SettingsRow(
                            icon: "questionmark.circle",
                            title: "Help & Support",
                            subtitle: "Get help with troubleshooting",
                            action: openHelpEmail
                        )
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // Rate the App
                        SettingsRow(
                            icon: "star.fill",
                            title: "Rate the App",
                            subtitle: "Share your experience on the App Store",
                            action: rateApp
                        )
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // Recommend the App
                        SettingsRow(
                            icon: "heart.fill",
                            title: "Recommend the App",
                            subtitle: "Share StoryChop with friends and family",
                            action: recommendApp
                        )
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // Submit Feedback
                        SettingsRow(
                            icon: "envelope.fill",
                            title: "Submit Feedback",
                            subtitle: "Send us your thoughts and suggestions",
                            action: submitFeedback
                        )
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .padding()
            }
            .navigationTitle("Settings")
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showExportSheet) {
            if let url = exportURL {
                SharingSheet(activityItems: [url]) {
                    // Clean up export file after sharing
                    exportService.cleanupExport(at: url)
                }
            }
        }
        .alert("Export Error", isPresented: $showExportErrorAlert) {
            Button("OK") { }
        } message: {
            Text(exportErrorMessage)
        }
        .onAppear {
            print("[DEBUG] SettingsView appeared with \(stories.count) stories")
        }
    }
    
    // MARK: - Settings Actions
    
    private func exportAllStories() {
        print("[DEBUG] Export all stories requested")
        
        guard !stories.isEmpty else {
            exportErrorMessage = "No stories to export"
            showExportErrorAlert = true
            return
        }
        
        let result = exportService.exportAllStories(stories: stories)
        
        switch result {
        case .success(let url):
            print("[DEBUG] Export successful: \(url.path)")
            exportURL = url
            showExportSheet = true
        case .failure(let error):
            print("[DEBUG] Export failed: \(error)")
            exportErrorMessage = error.localizedDescription
            showExportErrorAlert = true
        }
    }
    
    private func openHelpEmail() {
        print("[DEBUG] Help email requested")
        let email = "grace.anderson.au@gmail.com"
        let subject = "StoryChop Help Request"
        let body = "Hello,\n\nI need help with StoryChop. Here are the details:\n\n"
        
        if let url = createEmailURL(to: email, subject: subject, body: body) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        print("[DEBUG] Rate app requested")
        // App Store ID would be replaced with actual ID when app is published
        let appStoreURL = "https://apps.apple.com/app/id1234567890?action=write-review"
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func recommendApp() {
        print("[DEBUG] Recommend app requested")
        let appName = "StoryChop"
        let appDescription = "Record and preserve your personal memories through guided voice journaling"
        let shareText = "I've been using \(appName) to record my personal stories and memories. \(appDescription)"
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
    
    private func submitFeedback() {
        print("[DEBUG] Submit feedback requested")
        let email = "grace.anderson.au@gmail.com"
        let subject = "Feedback about StoryChop"
        let body = "Hello,\n\nHere's my feedback about StoryChop:\n\n"
        
        if let url = createEmailURL(to: email, subject: subject, body: body) {
            UIApplication.shared.open(url)
        }
    }
    
    private func createEmailURL(to email: String, subject: String, body: String) -> URL? {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"
        return URL(string: urlString)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Story.self, inMemory: true)
} 