import Foundation
import KiwiDomain
import Supabase

/// Email and password sign-in through Supabase Auth.
public struct SupabasePasswordAuth: PasswordAuth {
  private let auth: AuthClient

  public init(backend: SupabaseBackend) {
    auth = backend.client.auth
  }

  public func signIn(email: String, password: String) async throws(SignInError) {
    do {
      _ = try await auth.signIn(email: email, password: password)
    } catch {
      throw Self.signInError(for: error)
    }
  }

  public func signedInUsers() -> AsyncStream<SignedInUser?> {
    let auth = auth
    return AsyncStream { continuation in
      let task = Task {
        for await (event, session) in auth.authStateChanges {
          var current = session
          if event == .initialSession, let session, session.isExpired {
            // The stored session expired since the last launch. Wait for the refresh the SDK
            // starts (shared, not repeated), as supabase-js does before its initial session,
            // so the app doesn't flash sign-in; a failed refresh means signed out.
            current = try? await auth.session
          }
          continuation.yield(current.map(SignedInUser.init))
        }
        continuation.finish()
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }

  static func signInError(for error: any Error) -> SignInError {
    // The request never got an answer, or a gateway couldn't reach Auth: supabase-js's
    // AuthRetryableFetchError.
    if error is URLError { return .network }
    guard case .api(_, let code, _, let response) = error as? AuthError else { return .unknown }
    switch response.statusCode {
    case 429: return .rateLimited
    case 502...504: return .network
    default: break
    }
    switch code {
    case .invalidCredentials, .validationFailed: return .invalidCredentials
    case .emailNotConfirmed: return .emailNotConfirmed
    case .overRequestRateLimit: return .rateLimited
    default: return .unknown
    }
  }
}

extension SignedInUser {
  fileprivate init(_ session: Session) {
    self.init(id: session.user.id, email: session.user.email ?? "")
  }
}
