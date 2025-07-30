import SwiftUI
import UIKit

struct SharingSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let completion: () -> Void
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Configure activity view controller
        activityViewController.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks,
            .markupAsPDF
        ]
        
        // Handle completion
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[DEBUG] Activity view controller error: \(error)")
                }
                
                if completed {
                    print("[DEBUG] Story shared successfully via: \(activityType?.rawValue ?? "unknown")")
                } else {
                    print("[DEBUG] Story sharing cancelled")
                }
                
                // Call completion handler
                completion()
            }
        }
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
} 