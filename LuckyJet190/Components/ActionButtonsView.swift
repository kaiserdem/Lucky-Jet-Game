import SwiftUI

struct ActionButtonsView: View {
    let playerName: String
    let onCancel: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.custom("Digitalt", size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(20)
            }
            
            Button(action: onSave) {
                HStack {
                    Image(systemName: "trophy.fill")
                    Text("Save Score")
                }
                .font(.custom("Digitalt", size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.yellow, .orange]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: .yellow, radius: 5)
            }
            .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}

#Preview {
    ActionButtonsView(
        playerName: "Test Player",
        onCancel: {},
        onSave: {}
    )
    .background(Color.black.opacity(0.8))
}
