import SwiftUI
import WebKit

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            WebView(url: URL(string: "https://grace-anderson.github.io/storyChop/")!)
                .navigationTitle("Privacy Policy")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
        .onAppear {
            print("[DEBUG] PrivacyPolicyView appeared")
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed
    }
}

#Preview {
    PrivacyPolicyView()
} 
