import CoreLocation

public actor LocationService: LocationServiceProtocol {

    private let manager: CLLocationManager
    private let delegate: Delegate

    public init() {
        let delegate = Delegate()
        let manager = CLLocationManager()
        manager.delegate = delegate
        self.manager = manager
        self.delegate = delegate
    }

    public func requestCurrentLocation() async throws -> CLLocation {
        try await ensureAuthorized()
        return try await withCheckedThrowingContinuation { continuation in
            delegate.locationContinuation = continuation
            manager.requestLocation()
        }
    }

    public func geocode(address: String) async throws -> [CLPlacemark] {
        let geocoder = CLGeocoder()
        guard let placemarks = try await geocoder.geocodeAddressString(address) as [CLPlacemark]? else {
            throw CoreToolsError.notFound(resource: "address: \(address)")
        }
        return placemarks
    }

    public func reverseGeocode(latitude: Double, longitude: Double) async throws -> CLPlacemark {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        guard let placemarks = try await geocoder.reverseGeocodeLocation(location) as [CLPlacemark]?,
              let placemark = placemarks.first else {
            throw CoreToolsError.notFound(resource: "location: \(latitude), \(longitude)")
        }
        return placemark
    }

    public func startRegionMonitoring(identifier: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) async throws {
        try await ensureAuthorized()
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        manager.startMonitoring(for: region)
    }

    public func stopRegionMonitoring(identifier: String) async throws {
        let region = manager.monitoredRegions.first { $0.identifier == identifier }
        guard let region else {
            throw CoreToolsError.notFound(resource: "region: \(identifier)")
        }
        manager.stopMonitoring(for: region)
    }

    private func ensureAuthorized() async throws {
        let status = manager.authorizationStatus
        switch status {
        case .denied, .restricted:
            throw CoreToolsError.permissionDenied(
                framework: "CoreLocation",
                detail: "Location access is \(status == .denied ? "denied" : "restricted")"
            )
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            let granted = try await withCheckedThrowingContinuation { continuation in
                delegate.authorizationContinuation = continuation
            }
            if !granted {
                throw CoreToolsError.permissionDenied(
                    framework: "CoreLocation",
                    detail: "Location permission was not granted"
                )
            }
        default:
            break
        }
    }
}

private final class Delegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {

    var locationContinuation: CheckedContinuation<CLLocation, any Error>?
    var authorizationContinuation: CheckedContinuation<Bool, any Error>?

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation = authorizationContinuation else { return }
        authorizationContinuation = nil
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            continuation.resume(returning: true)
        case .denied, .restricted:
            continuation.resume(returning: false)
        case .notDetermined:
            break
        @unknown default:
            continuation.resume(returning: false)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        locationContinuation?.resume(throwing: CoreToolsError.operationFailed(operation: "requestLocation", underlyingError: error))
        locationContinuation = nil
    }
}
