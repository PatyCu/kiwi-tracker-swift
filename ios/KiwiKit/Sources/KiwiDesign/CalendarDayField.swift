import SwiftUI
import UIKit

/// A month calendar that chooses one day no later than `latest`, or none yet. It opens on the
/// chosen day's month. Tapping another day replaces it; tapping the chosen one keeps it, so
/// clearing is left to the caller. Today is drawn in kiwi; the system draws any other chosen day
/// in the label colour, which no public API changes.
///
/// It wraps `UICalendarView` because SwiftUI's calendars can't do all of this: a graphical
/// `DatePicker` always has a day chosen, and a `MultiDatePicker` can't open on a given month and
/// lets the day after its range end be chosen.
public struct CalendarDayField: UIViewRepresentable {
  @Binding private var day: DateComponents?
  private let latest: Date

  /// `day` holds at least the year, month and day.
  public init(day: Binding<DateComponents?>, latest: Date) {
    _day = day
    self.latest = latest
  }

  public func makeCoordinator() -> Coordinator { Coordinator(day: $day) }

  public func makeUIView(context: Context) -> UICalendarView {
    let view = UICalendarView()
    view.calendar = .current
    view.tintColor = UIColor(Palette.kiwi)
    view.availableDateRange = DateInterval(start: .distantPast, end: latest)
    let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
    selection.selectedDate = day
    view.selectionBehavior = selection
    if let day { view.visibleDateComponents = day }
    return view
  }

  public func updateUIView(_ view: UICalendarView, context: Context) {
    context.coordinator.day = $day
    guard let selection = view.selectionBehavior as? UICalendarSelectionSingleDate,
      !Self.isSameDay(selection.selectedDate, day)
    else { return }
    selection.setSelected(day, animated: false)
    if let day { view.setVisibleDateComponents(day, animated: false) }
  }

  public func sizeThatFits(
    _ proposal: ProposedViewSize, uiView: UICalendarView, context: Context
  ) -> CGSize? {
    let width = proposal.width ?? 320
    let height = uiView.systemLayoutSizeFitting(
      CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    ).height
    return CGSize(width: width, height: height)
  }

  private static func isSameDay(_ lhs: DateComponents?, _ rhs: DateComponents?) -> Bool {
    lhs?.year == rhs?.year && lhs?.month == rhs?.month && lhs?.day == rhs?.day
  }

  public final class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate {
    fileprivate var day: Binding<DateComponents?>

    fileprivate init(day: Binding<DateComponents?>) { self.day = day }

    public func dateSelection(
      _ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?
    ) {
      day.wrappedValue = dateComponents
    }

    /// A tap on the chosen day would deselect it, which passes `nil`; it's refused.
    public func dateSelection(
      _ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?
    ) -> Bool {
      dateComponents != nil
    }
  }
}
