import KiwiDesign
import KiwiDomain
import SwiftUI

/// A Pet's optional date of birth: "Select date" until one is chosen, then the day with a
/// button that clears it. Choosing opens a calendar capped at today, so a Pet can't be born in
/// the future. The day is kept as a calendar day, so it never shifts with the time zone.
struct PetBirthDateField: View {
  @Binding var birthDate: BirthDate?
  @State private var isPicking = false
  private let calendar = Calendar.current

  var body: some View {
    LabeledContent("Date of birth") {
      if let birthDate {
        HStack(spacing: 12) {
          Button(birthDate.date(in: calendar).formatted(date: .abbreviated, time: .omitted)) {
            isPicking.toggle()
          }
          .buttonStyle(.bordered)
          Button("Clear date", systemImage: "xmark.circle.fill") {
            self.birthDate = nil
            isPicking = false
          }
          .labelStyle(.iconOnly)
          .foregroundStyle(Palette.muted)
          .buttonStyle(.borderless)
        }
      } else {
        Button("Select date") {
          birthDate = BirthDate(.now, in: calendar)
          isPicking = true
        }
        .buttonStyle(.borderless)
      }
    }
    if isPicking, let birthDate {
      DatePicker(
        "Date of birth",
        selection: Binding(
          get: { birthDate.date(in: calendar) },
          set: { self.birthDate = BirthDate($0, in: calendar) }
        ),
        in: ...Date.now,
        displayedComponents: .date
      )
      .datePickerStyle(.graphical)
      .labelsHidden()
    }
  }
}
