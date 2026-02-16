import CoreTools

public struct PresentationEvaluator {
    public init() {}

    public func evaluate(
        header: EmbeddedViewHeader,
        metrics: RenderMetrics,
        suppressedRevision: String?
    ) -> PresentationEscalation {
        let mode = header.presentationHints.preferredModeValue

        if mode == .fullscreenRequired {
            return .required
        }

        if header.presentationHints.fullscreenAllowed == false {
            return .none
        }

        let isUnreadable = self.isUnreadable(header: header, metrics: metrics)
        guard isUnreadable || mode == .fullscreenPreferred else {
            return .none
        }

        if suppressedRevision == header.presentationHints.contentRevision {
            return .none
        }

        return .prompt
    }

    private func isUnreadable(
        header: EmbeddedViewHeader,
        metrics: RenderMetrics
    ) -> Bool {
        let heightThreshold = metrics.availableHeight * 0.55
        let exceedsHeightThreshold = metrics.renderedHeight > heightThreshold

        let exceedsReadableHeight: Bool
        if let minReadableHeight = header.presentationHints.minReadableHeight {
            exceedsReadableHeight = metrics.renderedHeight > minReadableHeight
        } else {
            exceedsReadableHeight = false
        }

        let exceedsMapListThreshold = metrics.hasMap && metrics.listCount > 8
        let exceedsFormThreshold = metrics.formFieldCount >= 10
        let inaccessiblePrimaryAction =
            metrics.isAccessibilityDynamicType && !metrics.isPrimaryActionInitiallyVisible

        return exceedsHeightThreshold ||
            exceedsReadableHeight ||
            exceedsMapListThreshold ||
            exceedsFormThreshold ||
            inaccessiblePrimaryAction
    }
}
