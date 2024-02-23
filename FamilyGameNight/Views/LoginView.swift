import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
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
                    .frame(maxWidth: 150)
                    .padding()
                    .foregroundColor(.white)
                    .background(LinearGradient(gradient: Gradient(colors: [.orange, .black, .orange]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(8)
            }
            GoogleSignInButton {
                signInWithGoogle()
            }
            .frame(width: 150)
            .padding(8)
            
            HStack{
                if authManager.authState == .signedOut {
                    Button { signInAnonymously() } label: {
                        Text("Skip")
                    }
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
                let result = try await authManager.signInAnonymously()
            }
            catch {
                // TODO: EH2 - handle frront end error for failed anonymous sign in
                print("Sign in anonymously Errir: \(error)")
            }
        }
    }
    
    // Sign in with google and authenticate with Firebase
    func signInWithGoogle() {
        GoogleSignInManager.shared.signInWithGoogle { user, error in
            if let error {
                // TODO: EH8: GoogleSignIn Failed Front end
                print("GoogleSignInError: failed to sign in with Gooogle, \(error)")
                // TODO: Create alert to display error to user
                return
            }
            
            guard let user = user else { return }
            Task {
                do {
                    let result = try await authManager.googleAuth(user)
                    if let result {
                        print("Google Sign in success! \(result.user.uid)")
                        dismiss()
                    }
                }
                catch {
                    print("GoogleSignInError: failed to authenicate with Google, \(error)")
                    // TODO: Display error message
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
