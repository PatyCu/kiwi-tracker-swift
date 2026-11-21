import Foundation
import KiwiDomain
import Observation
import Synchronization
import Testing

@testable import KiwiFeatures

private let alex = SignedInUser(id: UUID(), email: "alex@kiwi.test")

/// Starts following the session and waits until the model has subscribed.
private func observing(_ model: SessionModel, _ auth: RecordingPasswordAuth) async -> Task<
  Void, Never
> {
  let task = Task { await model.observe() }
  while !auth.subscribed { await Task.yield() }
  return task
}

/// Waits until the model has handled everything emitted so far.
private func settle() async {
  for _ in 0..<20 { await Task.yield() }
}

@Suite struct SessionModelTests {
  @Test func isLoadingUntilTheStoredSessionHasBeenRead() {
    let model = SessionModel(auth: RecordingPasswordAuth())

    #expect(model.state == .loading)
  }

  @Test func followsSignInAndSignOut() async {
    let auth = RecordingPasswordAuth()
    let model = SessionModel(auth: auth)
    let task = await observing(model, auth)
    defer { task.cancel() }

    auth.emit(nil)
    await settle()
    #expect(model.state == .signedOut)

    auth.emit(alex)
    await settle()
    #expect(model.state == .signedIn(alex))

    auth.emit(nil)
    await settle()
    #expect(model.state == .signedOut)
  }

  @Test func keepsTheSameStateWhenATokenRefreshReportsTheSameUser() async {
    let auth = RecordingPasswordAuth()
    let model = SessionModel(auth: auth)
    let task = await observing(model, auth)
    defer { task.cancel() }
    auth.emit(alex)
    await settle()
    let changed = Mutex(false)
    withObservationTracking {
      _ = model.state
    } onChange: {
      changed.withLock { $0 = true }
    }

    auth.emit(SignedInUser(id: alex.id, email: alex.email))
    await settle()

    #expect(model.state == .signedIn(alex))
    #expect(!changed.withLock { $0 })
  }

  @Test func unsubscribesWhenObservingStops() async {
    let auth = RecordingPasswordAuth()
    let task = await observing(SessionModel(auth: auth), auth)

    task.cancel()
    await task.value

    #expect(auth.unsubscribed)
  }
}
