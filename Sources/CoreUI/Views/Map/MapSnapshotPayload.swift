import Foundation

public struct CoordinatePayload: Codable, Sendable {
    public let latitude: Double
    public let longitude: Double

    enum CodingKeys: String, CodingKey {
        case lat
        case lng
        case latitude
        case longitude
    }

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let lat = try container.decodeIfPresent(Double.self, forKey: .lat) {
            self.latitude = lat
        } else {
            self.latitude = try container.decode(Double.self, forKey: .latitude)
        }

        if let lng = try container.decodeIfPresent(Double.self, forKey: .lng) {
            self.longitude = lng
        } else {
            self.longitude = try container.decode(Double.self, forKey: .longitude)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .lat)
        try container.encode(longitude, forKey: .lng)
    }
}

public struct MapAnnotationPayload: Codable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let coordinate: CoordinatePayload

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case coord
        case coordinate
    }

    public init(id: String, title: String, coordinate: CoordinatePayload) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)

        if let coord = try container.decodeIfPresent(CoordinatePayload.self, forKey: .coord) {
            self.coordinate = coord
        } else {
            self.coordinate = try container.decode(CoordinatePayload.self, forKey: .coordinate)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(coordinate, forKey: .coord)
    }
}

public struct MapRouteSummaryPayload: Codable, Sendable {
    public let originLabel: String
    public let destinationLabel: String
    public let distanceMeters: Double
    public let etaMinutes: Int

    enum CodingKeys: String, CodingKey {
        case originLabel
        case destinationLabel
        case distanceMeters
        case etaMinutes
        case distanceM
        case etaMin
    }

    public init(
        originLabel: String,
        destinationLabel: String,
        distanceMeters: Double,
        etaMinutes: Int
    ) {
        self.originLabel = originLabel
        self.destinationLabel = destinationLabel
        self.distanceMeters = distanceMeters
        self.etaMinutes = etaMinutes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.originLabel = try container.decodeIfPresent(String.self, forKey: .originLabel) ?? ""
        self.destinationLabel = try container.decodeIfPresent(String.self, forKey: .destinationLabel) ?? ""

        if let value = try container.decodeIfPresent(Double.self, forKey: .distanceM) {
            self.distanceMeters = value
        } else {
            self.distanceMeters = try container.decode(Double.self, forKey: .distanceMeters)
        }

        if let value = try container.decodeIfPresent(Int.self, forKey: .etaMin) {
            self.etaMinutes = value
        } else {
            self.etaMinutes = try container.decode(Int.self, forKey: .etaMinutes)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(originLabel, forKey: .originLabel)
        try container.encode(destinationLabel, forKey: .destinationLabel)
        try container.encode(distanceMeters, forKey: .distanceM)
        try container.encode(etaMinutes, forKey: .etaMin)
    }
}

public struct MapSnapshotPayload: EmbeddedPayload {
    public let center: CoordinatePayload
    public let latitudeDelta: Double
    public let longitudeDelta: Double
    public let annotations: [MapAnnotationPayload]
    public let geofenceRadiusMeters: Double?
    public let routeSummary: MapRouteSummaryPayload?
    public let summaryLines: [String]

    enum CodingKeys: String, CodingKey {
        case center
        case latitudeDelta
        case longitudeDelta
        case annotations
        case pins
        case geofenceRadiusMeters
        case routeSummary
        case route
        case summaryLines
        case summary
    }

    public init(
        center: CoordinatePayload,
        latitudeDelta: Double = 0.02,
        longitudeDelta: Double = 0.02,
        annotations: [MapAnnotationPayload],
        geofenceRadiusMeters: Double? = nil,
        routeSummary: MapRouteSummaryPayload? = nil,
        summaryLines: [String] = []
    ) {
        self.center = center
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
        self.annotations = annotations
        self.geofenceRadiusMeters = geofenceRadiusMeters
        self.routeSummary = routeSummary
        self.summaryLines = summaryLines
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.center = try container.decode(CoordinatePayload.self, forKey: .center)
        self.latitudeDelta = try container.decodeIfPresent(Double.self, forKey: .latitudeDelta) ?? 0.02
        self.longitudeDelta = try container.decodeIfPresent(Double.self, forKey: .longitudeDelta) ?? 0.02

        if let pins = try container.decodeIfPresent([MapAnnotationPayload].self, forKey: .pins) {
            self.annotations = pins
        } else {
            self.annotations = try container.decode([MapAnnotationPayload].self, forKey: .annotations)
        }

        self.geofenceRadiusMeters = try container.decodeIfPresent(Double.self, forKey: .geofenceRadiusMeters)

        if let route = try container.decodeIfPresent(MapRouteSummaryPayload.self, forKey: .route) {
            self.routeSummary = route
        } else {
            self.routeSummary = try container.decodeIfPresent(MapRouteSummaryPayload.self, forKey: .routeSummary)
        }

        if let summary = try container.decodeIfPresent([String].self, forKey: .summary) {
            self.summaryLines = summary
        } else {
            self.summaryLines = try container.decodeIfPresent([String].self, forKey: .summaryLines) ?? []
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(center, forKey: .center)
        try container.encode(latitudeDelta, forKey: .latitudeDelta)
        try container.encode(longitudeDelta, forKey: .longitudeDelta)
        try container.encode(annotations, forKey: .pins)
        try container.encodeIfPresent(geofenceRadiusMeters, forKey: .geofenceRadiusMeters)
        try container.encodeIfPresent(routeSummary, forKey: .route)
        try container.encode(summaryLines, forKey: .summary)
    }

    public var hasMap: Bool { true }
    public var listCount: Int { annotations.count + summaryLines.count + (routeSummary == nil ? 0 : 1) }
    public var formFieldCount: Int { 0 }
}
