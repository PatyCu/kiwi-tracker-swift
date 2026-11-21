#if DEBUG
  import KiwiDomain

  /// Sign-in for previews: succeeds, fails with an error, or never finishes.
  nonisolated struct PreviewPasswordAuth: PasswordAuth {
    enum Outcome {
      case succeeds
      case fails(SignInError)
      case staysSigningIn
    }

    static let setupError =
      "SUPABASE_URL is not set. Set it in the scheme's xcconfig in ios/Config and rebuild. "
      + "See docs/architecture.md#environments."

    var outcome = Outcome.succeeds
    var user: SignedInUser?

    func signIn(email: String, password: String) async throws(SignInError) {
      switch outcome {
      case .succeeds: return
      case .fails(let error): throw error
      case .staysSigningIn: try? await Task.sleep(for: .seconds(3600))
      }
    }

    func signedInUsers() -> AsyncStream<SignedInUser?> {
      AsyncStream { $0.yield(user) }
    }
  }
#endif
