import SwiftUI

struct HighScorePopupView: View {
    @ObservedObject var gameModel: GameModel
    @Binding var isPresented: Bool
    @State private var playerName: String = ""
    @State private var showError: Bool = false
    
    private var currentScore: Int {
        gameModel.score
    }
    
    private var currentLevelTitle: String {
        gameModel.currentLevel?.title ?? "Unknown Level"
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    // Don't dismiss on background tap
                }
            
            // Popup content
            VStack(spacing: 25) {
                // Header
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
                
                // Score info
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
                        
                        Text(String(format: "%.1fs", gameModel.flightTime))
                            .font(.custom("Digitalt", size: 20))
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
                
                // Name input
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
                            saveHighScore()
                        }
                    
                    if showError {
                        Text("Please enter your name")
                            .font(.custom("Digitalt", size: 14))
                            .foregroundColor(.red)
                    }
                }
                
                // Action buttons
                HStack(spacing: 20) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(.custom("Digitalt", size: 18))
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.7))
                            .cornerRadius(20)
                    }
                    
                    Button(action: {
                        saveHighScore()
                    }) {
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
            .padding(30)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.9), Color.blue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.yellow, lineWidth: 3)
            )
            .shadow(color: .yellow, radius: 20)
            .padding(.horizontal, 20)
        }
        .onAppear {
            // Auto-focus on text field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Focus logic would go here if needed
            }
        }
    }
    
    private func saveHighScore() {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            showError = true
            return
        }
        
        showError = false
        
        // Save the high score
        gameModel.addHighScore(
            playerName: trimmedName,
            score: currentScore,
            flightTime: gameModel.flightTime,
            levelTitle: currentLevelTitle
        )
        
        // Dismiss popup
        isPresented = false
    }
}

#Preview {
    HighScorePopupView(
        gameModel: GameModel(),
        isPresented: .constant(true)
    )
}
