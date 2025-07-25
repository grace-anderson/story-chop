import SwiftUI

struct SaveConfirmationStepView: View {
    let onDone: () -> Void
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)
            Text("Your story has been saved!")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            Button(action: {
                print("[DEBUG] Done tapped")
                onDone()
            }) {
                Text("Done")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .accessibilityLabel("Done")
        }
        .padding()
        .onAppear { print("[DEBUG] SaveConfirmationStepView appeared") }
    }
}

#Preview {
    SaveConfirmationStepView(onDone: {})
} 