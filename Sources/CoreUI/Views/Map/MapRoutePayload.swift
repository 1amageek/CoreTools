import Foundation

public struct MapRoutePayload: EmbeddedPayload {
    public struct Step: Codable, Sendable {
        public let stepID: String
        public let text: String
        public let distanceMeters: Double?

        enum CodingKeys: String, CodingKey {
            case stepID
            case id
            case text
            case instruction
            case distanceMeters
            case distanceM
        }

        public init(stepID: String, text: String, distanceMeters: Double? = nil) {
            self.stepID = stepID
            self.text = text
            self.distanceMeters = distanceMeters
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if let value = try container.decodeIfPresent(String.self, forKey: .stepID) {
                self.stepID = value
            } else {
                self.stepID = try container.decode(String.self, forKey: .id)
            }

            if let value = try container.decodeIfPresent(String.self, forKey: .text) {
                self.text = value
            } else {
                self.text = try container.decode(String.self, forKey: .instruction)
            }

            if let value = try container.decodeIfPresent(Double.self, forKey: .distanceM) {
                self.distanceMeters = value
            } else {
                self.distanceMeters = try container.decodeIfPresent(Double.self, forKey: .distanceMeters)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(stepID, forKey: .stepID)
            try container.encode(text, forKey: .text)
            try container.encodeIfPresent(distanceMeters, forKey: .distanceM)
        }
    }

    public let path: [CoordinatePayload]
    public let origin: MapAnnotationPayload?
    public let destination: MapAnnotationPayload?
    public let waypoints: [MapAnnotationPayload]
    public let routeSummary: MapRouteSummaryPayload?
    public let transport: String?
    public let steps: [Step]
    public let summaryLines: [String]

    enum CodingKeys: String, CodingKey {
        case path
        case polyline
        case origin
        case destination
        case waypoints
        case pins
        case routeSummary
        case route
        case transport
        case mode
        case steps
        case summaryLines
        case summary
    }

    public init(
        path: [CoordinatePayload],
        origin: MapAnnotationPayload? = nil,
        destination: MapAnnotationPayload? = nil,
        waypoints: [MapAnnotationPayload] = [],
        routeSummary: MapRouteSummaryPayload? = nil,
        transport: String? = nil,
        steps: [Step] = [],
        summaryLines: [String] = []
    ) {
        self.path = path
        self.origin = origin
        self.destination = destination
        self.waypoints = waypoints
        self.routeSummary = routeSummary
        self.transport = transport
        self.steps = steps
        self.summaryLines = summaryLines
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent([CoordinatePayload].self, forKey: .polyline) {
            self.path = value
        } else {
            self.path = try container.decode([CoordinatePayload].self, forKey: .path)
        }

        guard self.path.count >= 2 else {
            throw DecodingError.dataCorruptedError(
                forKey: .path,
                in: container,
                debugDescription: "route path must contain at least 2 coordinates"
            )
        }

        self.origin = try container.decodeIfPresent(MapAnnotationPayload.self, forKey: .origin)
        self.destination = try container.decodeIfPresent(MapAnnotationPayload.self, forKey: .destination)

        if let value = try container.decodeIfPresent([MapAnnotationPayload].self, forKey: .waypoints) {
            self.waypoints = value
        } else {
            self.waypoints = try container.decodeIfPresent([MapAnnotationPayload].self, forKey: .pins) ?? []
        }

        if let value = try container.decodeIfPresent(MapRouteSummaryPayload.self, forKey: .route) {
            self.routeSummary = value
        } else {
            self.routeSummary = try container.decodeIfPresent(MapRouteSummaryPayload.self, forKey: .routeSummary)
        }

        if let value = try container.decodeIfPresent(String.self, forKey: .transport) {
            self.transport = value
        } else {
            self.transport = try container.decodeIfPresent(String.self, forKey: .mode)
        }

        self.steps = try container.decodeIfPresent([Step].self, forKey: .steps) ?? []

        if let value = try container.decodeIfPresent([String].self, forKey: .summary) {
            self.summaryLines = value
        } else {
            self.summaryLines = try container.decodeIfPresent([String].self, forKey: .summaryLines) ?? []
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encodeIfPresent(origin, forKey: .origin)
        try container.encodeIfPresent(destination, forKey: .destination)
        try container.encode(waypoints, forKey: .waypoints)
        try container.encodeIfPresent(routeSummary, forKey: .route)
        try container.encodeIfPresent(transport, forKey: .transport)
        try container.encode(steps, forKey: .steps)
        try container.encode(summaryLines, forKey: .summary)
    }

    public var hasMap: Bool { true }
    public var listCount: Int { steps.count + summaryLines.count + waypoints.count + (routeSummary == nil ? 0 : 1) }
    public var formFieldCount: Int { 0 }
}
