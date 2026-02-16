import CoreTools
import Testing
@testable import CoreUI

@Test func promptsFullscreenWhenHeightExceedsThreshold() async throws {
    let header = EmbeddedViewHeader(
        embeddedViewType: EmbeddedViewType.mapSnapshot.rawValue,
        containerID: "container-1",
        title: "t",
        riskLevel: "medium",
        confirmationStyle: "single",
        presentationHints: UIPresentationHints(contentRevision: "r1")
    )

    let metrics = RenderMetrics(
        renderedHeight: 700,
        availableHeight: 1000,
        hasMap: false,
        listCount: 1,
        formFieldCount: 1,
        isAccessibilityDynamicType: false,
        isPrimaryActionInitiallyVisible: true
    )

    let result = PresentationEvaluator().evaluate(
        header: header,
        metrics: metrics,
        suppressedRevision: nil
    )

    #expect(result == .prompt)
}

@Test func requiresFullscreenWhenModeIsRequired() async throws {
    let header = EmbeddedViewHeader(
        embeddedViewType: EmbeddedViewType.mapSnapshot.rawValue,
        containerID: "container-1",
        title: "t",
        riskLevel: "medium",
        confirmationStyle: "single",
        presentationHints: UIPresentationHints(
            preferredMode: "fullscreenRequired",
            contentRevision: "r1"
        )
    )

    let metrics = RenderMetrics(
        renderedHeight: 100,
        availableHeight: 1000,
        hasMap: false,
        listCount: 0,
        formFieldCount: 0,
        isAccessibilityDynamicType: false,
        isPrimaryActionInitiallyVisible: true
    )

    let result = PresentationEvaluator().evaluate(
        header: header,
        metrics: metrics,
        suppressedRevision: nil
    )

    #expect(result == .required)
}

@Test func doesNotPromptWhenSameRevisionSuppressed() async throws {
    let header = EmbeddedViewHeader(
        embeddedViewType: EmbeddedViewType.mapSnapshot.rawValue,
        containerID: "container-1",
        title: "t",
        riskLevel: "medium",
        confirmationStyle: "single",
        presentationHints: UIPresentationHints(contentRevision: "same")
    )

    let metrics = RenderMetrics(
        renderedHeight: 700,
        availableHeight: 1000,
        hasMap: false,
        listCount: 1,
        formFieldCount: 1,
        isAccessibilityDynamicType: false,
        isPrimaryActionInitiallyVisible: true
    )

    let result = PresentationEvaluator().evaluate(
        header: header,
        metrics: metrics,
        suppressedRevision: "same"
    )

    #expect(result == .none)
}
