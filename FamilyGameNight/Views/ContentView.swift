import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                if isLoggedIn {
                    LoginView()
                } else {
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
