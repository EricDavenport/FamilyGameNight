import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLoginSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 16) {
                if authManager.authState == .signedIn {
                    Text(authManager.user?.displayName ?? "Name placeholder")
                        .font(.headline)
                    Text(authManager.user?.email ?? "Email placeholder")
                        .font(.subheadline)
                } else {
                    Text("Sign-in to view data")
                        .font(.headline)
                }
                
                Button {
                    if authManager.authState != .signedIn {
                        showLoginSheet = true
                    } else {
                        signOut()
                        
                    }
                } label: {
                    Text(authManager.authState != .signedIn ? "Sign-out" : "Sign-in")
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await authManager.signOut()
            }
            catch {
                // TODO: EH4 - handle front end of failed to signout
                print("Error: \(error)")
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
