import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isLoggedIn = false
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                if authManager.authState != .signedOut {
                    HomeView()
                } else {
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
