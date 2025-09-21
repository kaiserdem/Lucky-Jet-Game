
import SwiftUI

struct SpaceBackground: View {
    @State private var starOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height) + starOffset
                    )
                    .opacity(Double.random(in: 0.3...1.0))
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.3, green: 0.2, blue: 0.1),
                            Color(red: 0.2, green: 0.1, blue: 0.05)
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .position(x: UIScreen.main.bounds.width * 0.7, y: UIScreen.main.bounds.height + 100)
                .blur(radius: 2)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                starOffset = -UIScreen.main.bounds.height
            }
        }
    }
}
