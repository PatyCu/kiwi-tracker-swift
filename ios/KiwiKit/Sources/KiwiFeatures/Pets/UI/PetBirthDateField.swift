import KiwiDesign
import KiwiDomain
import SwiftUI

/// A Pet's optional date of birth: "Select date" until a day is tapped in the calendar it opens,
/// then the day with a button that clears it. Opening the calendar chooses nothing by itself.
/// The calendar is capped at today, so a Pet can't be born in the future, and the day is kept as
/// a calendar day, so it never shifts with the time zone.
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
        Button("Select date") { isPicking.toggle() }
          .buttonStyle(.borderless)
      }
    }
    if isPicking {
      CalendarDayField(day: chosenDay, latest: .now)
    }
  }

  private var chosenDay: Binding<DateComponents?> {
    Binding(
      get: {
        birthDate.map {
          DateComponents(calendar: calendar, year: $0.year, month: $0.month, day: $0.day)
        }
      },
      set: { day in
        guard let year = day?.year, let month = day?.month, let day = day?.day else { return }
        birthDate = BirthDate(year: year, month: month, day: day)
      }
    )
  }
}
