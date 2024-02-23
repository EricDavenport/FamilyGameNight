import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Text("Family Game Night")
                .font(.largeTitle)
                .fontWeight(.black)
                .padding(.bottom, 15)
            VStack {
                InputFieldView(data: $username, title: "Username")
                InputFieldView(data: $password, title: "Password")
            }.padding(.bottom, 16)
            Button(action: {}) {
                Text("Sign In")
                    .fontWeight(.heavy)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(LinearGradient(gradient: Gradient(colors: [.orange, .black, .orange]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(40)
            }
            HStack{
                Button { signInAnonymously() } label: {
                    Text("Skip")
                }

                Spacer()
                Text("Forgot Password")
                    .fontWeight(.thin)
                    .foregroundColor(Color.blue)
                    .underline()
            }
            .padding(.top)
            
        }
        .padding(16)
    }
    
    func signInAnonymously() {
        Task {
            do {
                let rresult = try await authManager.signInAnonymously()
            }
            catch {
                // TODO: EH2 - handle frront end error for failed anonymous sign in
                print("Sign in anonymously Errir: \(error)")
            }
        }
    }
}

#Preview {
    LoginView()
}
