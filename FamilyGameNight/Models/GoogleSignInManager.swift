import Foundation
import GoogleSignIn

class GoogleSignInManager {
    
    static let shared = GoogleSignInManager()
    
    typealias GoogleAuthResult = (GIDGoogleUser?, Error?) -> Void
    
    private init() {}
    
    func signInWithGoogle(_ completion: @escaping GoogleAuthResult) {
        // is user already signed in
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                completion(user, error)
            }
        } else { // else go on to sign in process
            // used to display log in for google window
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                completion(result?.user, error)
            }
        }
    }
    
    func signOutFromGoogle() {
        GIDSignIn.sharedInstance.signOut()
    }
}
