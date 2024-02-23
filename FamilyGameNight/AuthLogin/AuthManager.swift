import Foundation
import FirebaseAuth
import FirebaseCore

enum AuthState {
    case authenticated // Anonymously authenticated Firebase
    case signedIn // Authentucated in Firebase ising one of servicve providers, and not anonymous
    case signedOut // Not authenticated in Firebase
}

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var authState = AuthState.signedOut
    
    private var authStateHandle: AuthStateDidChangeListenerHandle!
    
    init() {
        configureAuthStateChanges()
    }
    
    func configureAuthStateChanges() {
        authStateHandle = Auth.auth().addStateDidChangeListener { auth, user in
            print("Auth changed: \(user != nil)")
            self.updateState(user: user)
        }
    }
    
    func removeAuthStateListener() {
        Auth.auth().removeStateDidChangeListener(authStateHandle)
    }
    
    func updateState(user: User?) {
        self.user = user
        let isAuthenticatedUser = user != nil
        let isAnonymous = user?.isAnonymous ?? false
        
        if isAuthenticatedUser {
            self.authState = isAnonymous ? .authenticated : .signedIn
        } else {
            self.authState = .signedOut
        }
    }
    
    func signInAnonymously() async throws -> AuthDataResult {
        do {
            let result = try await Auth.auth().signInAnonymously()
            print("FirebaseAuthError: Sign in anonymously, UID: \(String(describing: result.user.uid))")
            return result
        }
        catch {
            // TODO: EH1 - Error handling failed to sign in anonymously
            print("FirebaseAuthErrror: failed to sign in anonymously: \(error.localizedDescription)")
            throw error
        }
    }
}
