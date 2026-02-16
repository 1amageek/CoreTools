import CoreGraphics

public struct RenderMetrics: Sendable {
    public let renderedHeight: CGFloat
    public let availableHeight: CGFloat
    public let hasMap: Bool
    public let listCount: Int
    public let formFieldCount: Int
    public let isAccessibilityDynamicType: Bool
    public let isPrimaryActionInitiallyVisible: Bool

    public init(
        renderedHeight: CGFloat,
        availableHeight: CGFloat,
        hasMap: Bool,
        listCount: Int,
        formFieldCount: Int,
        isAccessibilityDynamicType: Bool,
        isPrimaryActionInitiallyVisible: Bool
    ) {
        self.renderedHeight = renderedHeight
        self.availableHeight = availableHeight
        self.hasMap = hasMap
        self.listCount = listCount
        self.formFieldCount = formFieldCount
        self.isAccessibilityDynamicType = isAccessibilityDynamicType
        self.isPrimaryActionInitiallyVisible = isPrimaryActionInitiallyVisible
    }
}
