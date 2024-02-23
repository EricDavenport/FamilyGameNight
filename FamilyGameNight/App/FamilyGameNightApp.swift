import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

@main
struct FamilyGameNightApp: App {
    // State manager
    @StateObject var authManager: AuthManager
    // register app delegate for firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // Use firebase library to configure APIs
        FirebaseApp.configure()
        
        // initialize the manager
        let authManager = AuthManager()
        _authManager = StateObject(wrappedValue: authManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // pass the authManager to the environmentObject
                .environmentObject(authManager)
        }
    }
}
