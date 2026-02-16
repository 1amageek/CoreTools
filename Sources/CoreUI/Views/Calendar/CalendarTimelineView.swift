import Foundation
import SwiftUI

public struct CalendarTimelineView: View {
    public let payload: CalendarTimelinePayload

    public init(payload: CalendarTimelinePayload) {
        self.payload = payload
    }

    private var sortedEvents: [CalendarEventPayload] {
        payload.events.sorted {
            (startDate(for: $0) ?? .distantFuture) < (startDate(for: $1) ?? .distantFuture)
        }
    }

    private var eventDaysInMonth: Set<Int> {
        let calendar = calendarForPayload
        return Set(sortedEvents.compactMap { event in
            guard let date = startDate(for: event) else {
                return nil
            }
            return calendar.component(.day, from: date)
        })
    }

    private var monthDates: [Date?] {
        let calendar = calendarForPayload
        let baseDate = startDate(for: sortedEvents.first ?? CalendarEventPayload(
            id: "fallback",
            title: "",
            start: ISO8601DateFormatter().string(from: Date()),
            end: ISO8601DateFormatter().string(from: Date())
        )) ?? Date()

        guard
            let monthRange = calendar.range(of: .day, in: .month, for: baseDate),
            let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate))
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leading = max(firstWeekday - calendar.firstWeekday, 0)

        var result: [Date?] = Array(repeating: nil, count: leading)

        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                result.append(date)
            }
        }

        return result
    }

    private var calendarForPayload: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        if let timezone = timezoneIdentifier, let tz = TimeZone(identifier: timezone) {
            calendar.timeZone = tz
        }
        return calendar
    }

    private var timezoneIdentifier: String? {
        payload.timezone
    }

    private var nextEvent: CalendarEventPayload? {
        let now = Date()
        return sortedEvents.first { event in
            guard let startDate = startDate(for: event) else {
                return false
            }
            return startDate >= now
        } ?? sortedEvents.first
    }

    public var body: some View {
        WatchCard {
            VStack(alignment: .leading, spacing: LayoutTokens.compact) {
                header

                monthOverview

                if let nextEvent {
                    upNextRow(for: nextEvent)
                }

                VStack(alignment: .leading, spacing: LayoutTokens.tiny) {
                    WatchSectionTitle(text: "Timeline")

                    ForEach(sortedEvents) { event in
                        timelineRow(for: event)
                    }
                }
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            WatchSectionTitle(text: "Calendar")
            Spacer()
            Text(timezoneAbbreviation)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(WatchPalette.secondaryText)
        }
    }

    private var monthOverview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(monthTitle)
                .font(.system(size: 14, weight: .bold, design: .rounded))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(WatchPalette.secondaryText)
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(monthDates.enumerated()), id: \.offset) { _, date in
                    if let date {
                        let day = calendarForPayload.component(.day, from: date)
                        Text("\(day)")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        eventDaysInMonth.contains(day)
                                            ? WatchPalette.accent.opacity(0.25)
                                            : Color.clear
                                    )
                            )
                    } else {
                        Color.clear
                            .frame(height: 14)
                    }
                }
            }
        }
        .padding(LayoutTokens.compact)
        .background(WatchPalette.elevated)
        .clipShape(RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius))
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM yyyy"

        let baseDate = startDate(for: sortedEvents.first ?? CalendarEventPayload(
            id: "fallback",
            title: "",
            start: ISO8601DateFormatter().string(from: Date()),
            end: ISO8601DateFormatter().string(from: Date())
        )) ?? Date()

        return formatter.string(from: baseDate)
    }

    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.veryShortStandaloneWeekdaySymbols
    }

    private func upNextRow(for event: CalendarEventPayload) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            WatchSectionTitle(text: "Up Next")

            HStack(alignment: .firstTextBaseline) {
                Text(event.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .lineLimit(2)
                Spacer()
                Text(countdownText(for: event))
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(WatchPalette.accent)
            }

            HStack(spacing: LayoutTokens.tiny) {
                WatchChip(text: timeRangeText(for: event))
                if event.conflict {
                    WatchChip(text: "重複", tint: WatchPalette.warning.opacity(0.28))
                }
            }
        }
        .padding(LayoutTokens.compact)
        .background(WatchPalette.elevated)
        .clipShape(RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius))
    }

    private func timelineRow(for event: CalendarEventPayload) -> some View {
        HStack(alignment: .top, spacing: LayoutTokens.compact) {
            Text(startTimeText(for: event))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(WatchPalette.secondaryText)
                .frame(width: 40, alignment: .leading)

            Rectangle()
                .fill(event.conflict ? WatchPalette.warning : WatchPalette.accent)
                .frame(width: 2, height: 28)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .lineLimit(2)

                HStack(spacing: LayoutTokens.tiny) {
                    if let location = event.location {
                        Label(location, systemImage: "mappin")
                            .lineLimit(1)
                    }
                    if let travelMinutes = event.travelMin {
                        Text("移動 \(travelMinutes)分")
                    }
                }
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundStyle(WatchPalette.secondaryText)
            }

            Spacer(minLength: 0)
        }
    }

    private var timezoneAbbreviation: String {
        guard let timezone = timezoneIdentifier, let tz = TimeZone(identifier: timezone) else {
            return "LOCAL"
        }
        return tz.abbreviation() ?? timezone
    }

    private func startDate(for event: CalendarEventPayload) -> Date? {
        date(from: event.start)
    }

    private func endDate(for event: CalendarEventPayload) -> Date? {
        date(from: event.end)
    }

    private func date(from text: String) -> Date? {
        let primary = ISO8601DateFormatter()
        primary.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = primary.date(from: text) {
            return date
        }

        let fallback = ISO8601DateFormatter()
        return fallback.date(from: text)
    }

    private func startTimeText(for event: CalendarEventPayload) -> String {
        guard let start = startDate(for: event) else {
            return "--:--"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = timezoneIdentifier.flatMap(TimeZone.init(identifier:))
        return formatter.string(from: start)
    }

    private func timeRangeText(for event: CalendarEventPayload) -> String {
        guard let start = startDate(for: event), let end = endDate(for: event) else {
            return "時刻不明"
        }

        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        if let timezone = timezoneIdentifier, let tz = TimeZone(identifier: timezone) {
            formatter.timeZone = tz
        }
        return formatter.string(from: start, to: end)
    }

    private func countdownText(for event: CalendarEventPayload) -> String {
        guard let start = startDate(for: event) else {
            return "--"
        }

        let seconds = Int(start.timeIntervalSinceNow)
        if seconds <= 0 {
            return "Now"
        }

        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)m"
        }

        let hours = minutes / 60
        let remainMinutes = minutes % 60
        if remainMinutes == 0 {
            return "\(hours)h"
        }
        return "\(hours)h\(remainMinutes)m"
    }
}

#Preview("CalendarTimelineView/Watch") {
    ZStack {
        Color.black.ignoresSafeArea()

        CalendarTimelineView(
            payload: CalendarTimelinePayload(
                timezone: "Asia/Tokyo",
                events: [
                    CalendarEventPayload(
                        id: "e1",
                        title: "保育園お迎え",
                        start: "2026-02-16T17:00:00+09:00",
                        end: "2026-02-16T17:30:00+09:00",
                        location: "中央保育園",
                        travelMin: 20,
                        conflict: false
                    ),
                    CalendarEventPayload(
                        id: "e2",
                        title: "オンライン会議",
                        start: "2026-02-16T17:15:00+09:00",
                        end: "2026-02-16T18:00:00+09:00",
                        location: nil,
                        travelMin: nil,
                        conflict: true
                    ),
                ]
            )
        )
        .padding(LayoutTokens.compact)
        .frame(maxWidth: .infinity, minHeight: 360)
    }
}
