import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

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
    
    func signOut() async throws {
        if let user = Auth.auth().currentUser {
            do {
                // TODO: Sign out frrom the signed-in provider
                try Auth.auth().signOut()
            }
            catch let error as NSError {
                 // TODO: EH3 - failed to signout from provider
                print("FireebaseAuthError: Failed to sign out from Firebase, \(error)")
                throw error
            }
        }
    }
    
    private func authenticateUser(credentials: AuthCredential) async throws -> AuthDataResult? {
        if Auth.auth().currentUser != nil {
            return try await authLink(credentials: credentials)
        } else {
            return try await authSignIn(credentials: credentials)
        }
    }
    
    private func authSignIn(credentials: AuthCredential) async throws -> AuthDataResult? {
        do {
            let result = try await Auth.auth().signIn(with: credentials)
            updateState(user: result.user)
            return result
        }
        catch {
            // TODO: EH6 - failed to authorize user in the signIn(with:) method
            print("FirebaseAuthError: signIn(with:) failed, \(error)")
            throw error
        }
    }
    
    private func authLink(credentials: AuthCredential) async throws -> AuthDataResult? {
        do {
            guard let user = Auth.auth().currentUser else { return nil }
            let result = try await user.link(with: credentials)
            await updateDisplayName(for: result.user)
            updateState(user: result.user)
            return result
        }
        catch {
            // TODO: EH5 - failed to authorize user in the link(with: ) method
            print("FirebaseAuthError: link(with: ) failed, \(error)")
            throw error
        }
    }
    
    private func updateDisplayName(for user: User) async {
        if let currentDisplayName = Auth.auth().currentUser?.displayName, !currentDisplayName.isEmpty {
            // current user is non-empty - do not overwrtie
        } else {
            let displayName = user.providerData.first?.displayName
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            do {
                try await changeRequest.commitChanges()
            }
            catch {
                // TODO: EH7 - failed to update user display name
                print("FirebaseAutnError: Failed to update the user's displayname, \(error)")
            }
        }
    }
    
    // MARK: GOOGLE Sign in
    func googleAuth(_ user: GIDGoogleUser) async throws -> AuthDataResult? {
        guard let idToken = user.idToken?.tokenString else { return nil }
        
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        do {
            return try await authenticateUser(credentials: credentials)
        }
        catch {
            // TODO: EH8: google Signin failed
            print("FirebaseAuthError: googleAuth(user:) failed, \(error)")
            throw error
        }
    }
    
    
    func firebaseProvidersSignOut(_ user: User) {
        let providers = user.providerData.map { $0.providerID }.joined(separator: ", ")
        
        if providers.contains("google.com") {
            GoogleSignInManager.shared.signOutFromGoogle()
        }
    }

}
