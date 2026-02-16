import Foundation

public struct HealthMetricPayload: Codable, Sendable, Identifiable {
    public let id: String
    public let label: String
    public let unit: String
    public let current: Double
    public let prev: Double
    public let series: [Double]

    enum CodingKeys: String, CodingKey {
        case id
        case label
        case unit
        case current
        case prev
        case series
        case latestValue
        case previousValue
        case sparkline
    }

    public init(
        id: String,
        label: String,
        unit: String,
        current: Double,
        prev: Double,
        series: [Double]
    ) {
        self.id = id
        self.label = label
        self.unit = unit
        self.current = current
        self.prev = prev
        self.series = series
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.label = try container.decode(String.self, forKey: .label)
        self.unit = try container.decode(String.self, forKey: .unit)

        if let value = try container.decodeIfPresent(Double.self, forKey: .current) {
            self.current = value
        } else {
            self.current = try container.decode(Double.self, forKey: .latestValue)
        }

        if let value = try container.decodeIfPresent(Double.self, forKey: .prev) {
            self.prev = value
        } else {
            self.prev = try container.decode(Double.self, forKey: .previousValue)
        }

        if let value = try container.decodeIfPresent([Double].self, forKey: .series) {
            self.series = value
        } else {
            self.series = try container.decode([Double].self, forKey: .sparkline)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(unit, forKey: .unit)
        try container.encode(current, forKey: .current)
        try container.encode(prev, forKey: .prev)
        try container.encode(series, forKey: .series)
    }
}

public struct HealthTrendPayload: EmbeddedPayload {
    public let period: String?
    public let metrics: [HealthMetricPayload]
    public let alerts: [String]

    enum CodingKeys: String, CodingKey {
        case period
        case periodLabel
        case metrics
        case alerts
    }

    public init(period: String?, metrics: [HealthMetricPayload], alerts: [String] = []) {
        self.period = period
        self.metrics = metrics
        self.alerts = alerts
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(String.self, forKey: .period) {
            self.period = value
        } else {
            self.period = try container.decodeIfPresent(String.self, forKey: .periodLabel)
        }

        self.metrics = try container.decode([HealthMetricPayload].self, forKey: .metrics)
        self.alerts = try container.decodeIfPresent([String].self, forKey: .alerts) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(period, forKey: .period)
        try container.encode(metrics, forKey: .metrics)
        try container.encode(alerts, forKey: .alerts)
    }

    public var hasMap: Bool { false }
    public var listCount: Int { metrics.count + alerts.count }
    public var formFieldCount: Int { 0 }
}
