import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("[Settings] App settings and info will appear here.")
                    .font(.title2)
                    .padding()
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            print("[DEBUG] SettingsView appeared")
        }
    }
}

#Preview {
    SettingsView()
} 