import SwiftUI

struct StatisticsView: View {
    let totalGames: Int
    let bestScore: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text("📊 Statistics")
                .font(.custom("Digitalt", size: 18))
                .foregroundColor(.white)
            
            HStack {
                Text("Total Games:")
                    .font(.custom("Digitalt", size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(totalGames)")
                    .font(.custom("Digitalt", size: 16))
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Best Score:")
                    .font(.custom("Digitalt", size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(bestScore)")
                    .font(.custom("Digitalt", size: 16))
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
    }
}

#Preview {
    StatisticsView(
        totalGames: 25,
        bestScore: 1500
    )
    .background(Color.black.opacity(0.8))
}
