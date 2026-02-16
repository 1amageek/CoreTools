import Testing
import CoreLocation
@testable import CoreTools

@Suite("GetCurrentLocationTool Tests")
struct GetCurrentLocationToolTests {

    @Test("Returns current location successfully")
    func getCurrentLocation() async throws {
        let mock = MockLocationService()
        mock.currentLocation = CLLocation(latitude: 35.6812, longitude: 139.7671)
        let tool = GetCurrentLocationTool(service: mock)
        let args = try GetCurrentLocationTool.Arguments(GeneratedContent(properties: [:]))
        let result = try await tool.call(arguments: args)
        #expect(result.coordinate.latitude == 35.6812)
        #expect(result.coordinate.longitude == 139.7671)
        #expect(result.message.contains("successfully"))
    }

    @Test("Propagates service errors")
    func serviceError() async throws {
        let mock = MockLocationService()
        mock.shouldThrow = CoreToolsError.permissionDenied(framework: "CoreLocation", detail: "denied")
        let tool = GetCurrentLocationTool(service: mock)
        let args = try GetCurrentLocationTool.Arguments(GeneratedContent(properties: [:]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
