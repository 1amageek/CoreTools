import Charts
import SwiftUI

public struct HealthTrendView: View {
    public let payload: HealthTrendPayload

    public init(payload: HealthTrendPayload) {
        self.payload = payload
    }

    public var body: some View {
        WatchCard {
            VStack(alignment: .leading, spacing: LayoutTokens.compact) {
                HStack(alignment: .firstTextBaseline) {
                    WatchSectionTitle(text: "Health")
                    Spacer()
                    Text(payload.period ?? "")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(WatchPalette.secondaryText)
                }

                ForEach(payload.metrics) { metric in
                    metricRow(metric)
                }

                if !payload.alerts.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(payload.alerts, id: \.self) { alert in
                            Label(alert, systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .lineLimit(2)
                                .foregroundStyle(WatchPalette.warning)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metricRow(_ metric: HealthMetricPayload) -> some View {
        let isUp = metric.current >= metric.prev
        let delta = metric.current - metric.prev
        let trendColor: Color = isUp ? .green : .orange

        return VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: LayoutTokens.tiny) {
                Text(metric.label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .lineLimit(1)

                Spacer()

                Text(valueText(metric.current, unit: metric.unit))
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .monospacedDigit()

                Text(deltaText(delta, unit: metric.unit))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(trendColor)
                    .lineLimit(1)
            }

            Chart {
                ForEach(Array(metric.series.enumerated()), id: \.offset) { index, value in
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Value", value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(.init(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(trendColor)

                    AreaMark(
                        x: .value("Index", index),
                        y: .value("Value", value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [trendColor.opacity(0.25), trendColor.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.white.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: LayoutTokens.chipRadius))
            }
            .frame(height: 42)
        }
        .padding(LayoutTokens.compact)
        .background(WatchPalette.elevated)
        .clipShape(RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius))
    }

    private func deltaText(_ delta: Double, unit: String) -> String {
        if delta == 0 {
            return "±0"
        }

        let sign = delta > 0 ? "+" : ""
        if delta.rounded() == delta {
            return "\(sign)\(Int(delta))\(unit)"
        }
        return String(format: "%@%.1f%@", sign, delta, unit)
    }

    private func valueText(_ value: Double, unit: String) -> String {
        if value.rounded() == value {
            return "\(Int(value))\(unit)"
        }
        return String(format: "%.1f%@", value, unit)
    }
}

#Preview("HealthTrendView/Watch") {
    ZStack {
        Color.black.ignoresSafeArea()

        HealthTrendView(
            payload: HealthTrendPayload(
                period: "過去7日",
                metrics: [
                    HealthMetricPayload(
                        id: "steps",
                        label: "歩数",
                        unit: "歩",
                        current: 8420,
                        prev: 7100,
                        series: [5600, 6100, 6800, 7200, 7000, 7900, 8420]
                    ),
                    HealthMetricPayload(
                        id: "heart",
                        label: "安静時心拍",
                        unit: "bpm",
                        current: 61,
                        prev: 64,
                        series: [66, 65, 64, 64, 63, 62, 61]
                    ),
                ],
                alerts: ["睡眠時間が平日平均より短い"]
            )
        )
        .padding(LayoutTokens.compact)
        .frame(maxWidth: .infinity, minHeight: 380)
    }
}
