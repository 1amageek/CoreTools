import Foundation

public struct HealthMetricPayload: Codable, Sendable, Identifiable {
    public let id: String
    public let label: String
    public let unit: String
    public let latestValue: Double
    public let previousValue: Double
    public let sparkline: [Double]

    public init(
        id: String,
        label: String,
        unit: String,
        latestValue: Double,
        previousValue: Double,
        sparkline: [Double]
    ) {
        self.id = id
        self.label = label
        self.unit = unit
        self.latestValue = latestValue
        self.previousValue = previousValue
        self.sparkline = sparkline
    }
}

public struct HealthTrendPayload: EmbeddedPayload {
    public let periodLabel: String
    public let metrics: [HealthMetricPayload]
    public let alerts: [String]

    public init(periodLabel: String, metrics: [HealthMetricPayload], alerts: [String] = []) {
        self.periodLabel = periodLabel
        self.metrics = metrics
        self.alerts = alerts
    }

    public var hasMap: Bool { false }
    public var listCount: Int { metrics.count + alerts.count }
    public var formFieldCount: Int { 0 }
}
