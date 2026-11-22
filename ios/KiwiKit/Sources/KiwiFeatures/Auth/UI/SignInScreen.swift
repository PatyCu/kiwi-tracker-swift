import KiwiDesign
import KiwiDomain
import SwiftUI

/// Email and password sign-in, as the reference app's `SignInScreen`.
struct SignInScreen: View {
  private enum Field {
    case email, password
  }

  @State private var form: PasswordSignInForm
  @FocusState private var focusedField: Field?
  @State private var passwordVisible = false

  init(auth: any PasswordAuth) {
    self.init(form: PasswordSignInForm(auth: auth))
  }

  init(form: PasswordSignInForm) {
    _form = State(initialValue: form)
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        AppNameLabel()
        Text("Sign in")
          .font(.largeTitle.weight(.heavy))
          .foregroundStyle(Palette.text)
          .accessibilityAddTraits(.isHeader)
          .padding(.top, 32)
        Text("Sign in with the account you were given.")
          .font(.subheadline)
          .foregroundStyle(Palette.muted)
          .padding(.top, 8)
        fieldLabel("EMAIL")
        TextField(
          "Email",
          text: $form.email,
          prompt: Text(verbatim: "you@example.com").foregroundStyle(Palette.muted)
        )
        .textContentType(.username)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focusedField, equals: .email)
        .onSubmit { focusedField = .password }
        .padding(14)
        .inputFieldStyle()
        fieldLabel("PASSWORD")
        HStack(spacing: 0) {
          passwordInput
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.go)
            .focused($focusedField, equals: .password)
            .onSubmit(submit)
            .padding(14)
          // The icon shows the current state: an open, tinted eye while the password is visible.
          Toggle("Show password", isOn: $passwordVisible)
            .toggleStyle(PasswordVisibilityToggleStyle())
        }
        .fixedSize(horizontal: false, vertical: true)
        .inputFieldStyle()
        .onChange(of: passwordVisible) {
          // Swapping the field drops focus; give it back so the keyboard stays up.
          guard focusedField == .password else { return }
          Task { focusedField = .password }
        }
        if let error = form.error {
          Text(error)
            .font(.subheadline)
            .foregroundStyle(Palette.coral)
            .padding(.top, 12)
        }
        Button(action: submit) {
          Text(form.signingIn ? "Signing in…" : "Sign in")
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 14))
        .controlSize(.large)
        .tint(Palette.kiwi)
        .disabled(form.signingIn)
        .padding(.top, 18)
      }
      .disabled(form.signingIn)
      .frame(maxWidth: 420)
      .padding(20)
      .frame(maxWidth: .infinity)
    }
    .defaultScrollAnchor(.center, for: .alignment)
    .scrollBounceBehavior(.basedOnSize)
    .scrollDismissesKeyboard(.interactively)
    .background(Palette.bg)
    .tint(Palette.kiwi)
    .onAppear { focusedField = .email }
    .onChange(of: form.error) { _, error in
      // The reference marks the error as an alert, which screen readers announce.
      if let error { AccessibilityNotification.Announcement(error).post() }
    }
  }

  @ViewBuilder private var passwordInput: some View {
    if passwordVisible {
      TextField("Password", text: $form.password, prompt: Text(""))
    } else {
      SecureField("Password", text: $form.password, prompt: Text(""))
    }
  }

  private func fieldLabel(_ text: String) -> some View {
    Text(text)
      .font(.caption2.weight(.heavy))
      .tracking(1.3)
      .foregroundStyle(Palette.muted)
      .padding(.top, 24)
      .padding(.bottom, 10)
      .accessibilityHidden(true)
  }

  private func submit() {
    Task { await form.submit() }
  }
}

/// The eye button beside the password, read by VoiceOver as a "Show password" switch.
private struct PasswordVisibilityToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    Button {
      configuration.isOn.toggle()
    } label: {
      Image(systemName: configuration.isOn ? "eye" : "eye.slash")
        .font(.title3)
        .foregroundStyle(configuration.isOn ? Palette.kiwi : Palette.muted)
        .padding(.horizontal, 14)
        .frame(maxHeight: .infinity)
        .contentShape(.rect)
    }
    .buttonStyle(.plain)
  }
}

extension View {
  fileprivate func inputFieldStyle() -> some View {
    font(.callout)
      .foregroundStyle(Palette.text)
      .frame(minHeight: 50)
      .background(Palette.surface2, in: .rect(cornerRadius: 14))
      .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.line))
  }
}

#if DEBUG
  private func filledForm(_ outcome: PreviewPasswordAuth.Outcome) -> PasswordSignInForm {
    let form = PasswordSignInForm(auth: PreviewPasswordAuth(outcome: outcome))
    form.email = "alex@kiwi.test"
    form.password = "kiwi-local-dev"
    return form
  }

  #Preview("Empty") {
    SignInScreen(auth: PreviewPasswordAuth())
  }

  #Preview("Signing in") {
    let form = filledForm(.staysSigningIn)
    SignInScreen(form: form).task { await form.submit() }
  }

  #Preview("Error") {
    let form = filledForm(.fails(.invalidCredentials))
    SignInScreen(form: form).task { await form.submit() }
  }

  #Preview("Error, dark") {
    let form = filledForm(.fails(.network))
    SignInScreen(form: form)
      .task { await form.submit() }
      .preferredColorScheme(.dark)
  }
#endif
