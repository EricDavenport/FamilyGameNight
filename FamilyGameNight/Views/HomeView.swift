 import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    HomeView()
}
