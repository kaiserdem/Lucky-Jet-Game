import SwiftUI

struct ScoreInfoView: View {
    let currentScore: Int
    let currentLevelTitle: String
    let flightTime: Double
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Score:")
                    .font(.custom("Digitalt", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(currentScore)")
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(.yellow)
            }
            
            HStack {
                Text("Level:")
                    .font(.custom("Digitalt", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(currentLevelTitle)
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(.cyan)
            }
            
            HStack {
                Text("Flight Time:")
                    .font(.custom("Digitalt", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.1fs", flightTime))
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
    }
}

#Preview {
    ScoreInfoView(
        currentScore: 1250,
        currentLevelTitle: "Easy 1",
        flightTime: 7.5
    )
    .background(Color.black.opacity(0.8))
}
