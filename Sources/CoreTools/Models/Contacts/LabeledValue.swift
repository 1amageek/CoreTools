
@Generable
public struct LabeledValue: Sendable {
    @Guide(description: "Label for the value, e.g. home, work")
    public var label: String?

    @Guide(description: "The value")
    public var value: String

    public init(label: String?, value: String) {
        self.label = label
        self.value = value
    }
}
