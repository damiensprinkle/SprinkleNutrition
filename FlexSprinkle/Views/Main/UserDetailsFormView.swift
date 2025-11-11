import SwiftUI

struct UserDetailsFormView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var userManager: UserManager
    
    @State private var name: String = ""
    @State private var animate = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .overlay(
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .offset(x: animate ? 100 : -100, y: animate ? -150 : 150)
                        .blur(radius: 40)
                        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
                )
            
            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("Welcome...")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .transition(.opacity.combined(with: .scale))
                    
                    Text("Let's get to know you")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 60)
                
                // Name entry card
                VStack(spacing: 16) {
                    TextField("Your name", text: $name)
                        .padding()
                        .background(.myWhite)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        saveUserDetails()
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(name.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(name.isEmpty)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .shadow(radius: 10)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            if let userDetails = userManager.userDetails {
                name = userDetails.name ?? ""
            }
            animate = true
        }
    }
    
    private func saveUserDetails() {
        userManager.updateUserName(name: name) // unit not used anymore
        isPresented = false
    }
}
