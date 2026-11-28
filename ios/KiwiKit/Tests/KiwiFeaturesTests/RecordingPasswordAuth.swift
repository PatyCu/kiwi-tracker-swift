import KiwiDomain
import Synchronization

/// Sign-in for tests: records the attempts, answers with `result`, counts sign-outs, which fail
/// while `signOutFails` is set, and lets the test emit users.
nonisolated final class RecordingPasswordAuth: PasswordAuth {
  private struct State {
    var result: Result<Void, SignInError> = .success(())
    var attempts: [(email: String, password: String)] = []
    var continuation: AsyncStream<SignedInUser?>.Continuation?
    var unsubscribed = false
    var signOuts = 0
    var signOutFails = false
  }

  private let state = Mutex(State())

  var attempts: [(email: String, password: String)] { state.withLock { $0.attempts } }
  var unsubscribed: Bool { state.withLock { $0.unsubscribed } }
  var signOuts: Int { state.withLock { $0.signOuts } }
  var subscribed: Bool { state.withLock { $0.continuation != nil } }
  var signOutFails: Bool {
    get { state.withLock { $0.signOutFails } }
    set { state.withLock { $0.signOutFails = newValue } }
  }

  func answer(_ result: Result<Void, SignInError>) {
    state.withLock { $0.result = result }
  }

  /// Reports `user` to whoever follows `signedInUsers()`.
  func emit(_ user: SignedInUser?) {
    _ = state.withLock { $0.continuation }?.yield(user)
  }

  func signIn(email: String, password: String) async throws(SignInError) {
    let result = state.withLock {
      $0.attempts.append((email, password))
      return $0.result
    }
    try result.get()
  }

  func signOut() async throws {
    let fails = state.withLock {
      $0.signOuts += 1
      return $0.signOutFails
    }
    if fails { throw SignOutFailed() }
  }

  func signedInUsers() -> AsyncStream<SignedInUser?> {
    let (stream, continuation) = AsyncStream<SignedInUser?>.makeStream()
    continuation.onTermination = { [weak self] _ in self?.state.withLock { $0.unsubscribed = true }
    }
    state.withLock { $0.continuation = continuation }
    return stream
  }
}

struct SignOutFailed: Error {}
