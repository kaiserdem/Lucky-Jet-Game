import SwiftUI

struct HighScoreHeaderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("🏆")
                .font(.custom("Digitalt", size: 48))
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: true)
            
            Text("New High Score!")
                .font(.custom("Digitalt", size: 28))
                .foregroundColor(.yellow)
                .shadow(color: .yellow, radius: 5)
            
            Text("Congratulations! You made it to the top 10!")
                .font(.custom("Digitalt", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    HighScoreHeaderView()
        .background(Color.black.opacity(0.8))
}
