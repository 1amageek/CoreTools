
@Generable
public struct PlaceSearchResult: Sendable, PromptRepresentable {
    @Guide(description: "List of found places")
    public var places: [PlaceItem]

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(places: [PlaceItem], message: String) {
        self.places = places
        self.message = message
    }
}
