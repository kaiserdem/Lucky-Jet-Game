import SwiftUI

struct NameInputView: View {
    @Binding var playerName: String
    @Binding var showError: Bool
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Enter your name:")
                .font(.custom("Digitalt", size: 18))
                .foregroundColor(.white)
            
            TextField("Player Name", text: $playerName)
                .font(.custom("Digitalt", size: 20))
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(playerName.isEmpty ? Color.gray : Color.blue, lineWidth: 2)
                )
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    onSave()
                }
            
            if showError {
                Text("Please enter your name")
                    .font(.custom("Digitalt", size: 14))
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    @State var playerName = ""
    @State var showError = false
    
    return NameInputView(
        playerName: $playerName,
        showError: $showError,
        onSave: {}
    )
    .background(Color.black.opacity(0.8))
}
