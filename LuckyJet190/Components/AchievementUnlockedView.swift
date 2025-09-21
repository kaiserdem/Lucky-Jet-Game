import SwiftUI

struct AchievementUnlockedView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("🎯 Achievement Unlocked!")
                .font(.custom("Digitalt", size: 20))
                .foregroundColor(.yellow)
                .shadow(color: .yellow, radius: 3)
            
            Text("You've proven your skills as a space pilot!")
                .font(.custom("Digitalt", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Keep flying and reach even higher scores!")
                .font(.custom("Digitalt", size: 14))
                .foregroundColor(.cyan)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
    }
}

#Preview {
    AchievementUnlockedView()
        .background(Color.black.opacity(0.8))
}
