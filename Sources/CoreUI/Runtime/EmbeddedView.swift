import CoreTools
import SwiftUI

public struct EmbeddedViewModel: Sendable {
    public let header: EmbeddedViewHeader
    public let payload: DecodedEmbeddedPayload

    public init(header: EmbeddedViewHeader, payload: DecodedEmbeddedPayload) {
        self.header = header
        self.payload = payload
    }
}

public struct EmbeddedView: View {
    private let model: EmbeddedViewModel?
    private let headerJSON: String?
    private let payloadJSON: String?
    private let actionHandler: EmbeddedViewActionHandler
    private let presentationDriver: PresentationDriver
    private let decoder: SchemaDecoder
    private let registry: ScreenRegistry
    @State private var renderedHeight: CGFloat = 0
    @State private var showFullscreenPrompt = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(
        model: EmbeddedViewModel,
        actionHandler: EmbeddedViewActionHandler,
        presentationDriver: PresentationDriver,
        registry: ScreenRegistry = ScreenRegistry()
    ) {
        self.model = model
        self.headerJSON = nil
        self.payloadJSON = nil
        self.actionHandler = actionHandler
        self.presentationDriver = presentationDriver
        self.decoder = SchemaDecoder()
        self.registry = registry
    }

    public init(
        headerJSON: String,
        payloadJSON: String,
        actionHandler: EmbeddedViewActionHandler,
        presentationDriver: PresentationDriver,
        decoder: SchemaDecoder = SchemaDecoder(),
        registry: ScreenRegistry = ScreenRegistry()
    ) {
        self.model = nil
        self.headerJSON = headerJSON
        self.payloadJSON = payloadJSON
        self.actionHandler = actionHandler
        self.presentationDriver = presentationDriver
        self.decoder = decoder
        self.registry = registry
    }

    public var body: some View {
        GeometryReader { proxy in
            let model = self.decodeModel()
            let state = EmbeddedStateStore.shared.state(for: model.header.containerID)
            let availableHeight = max(proxy.size.height, 1)

            registry
                .render(
                    header: model.header,
                    payload: model.payload,
                    state: state,
                    actionHandler: actionHandler,
                    presentationDriver: presentationDriver
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(
                    GeometryReader { contentProxy in
                        Color.clear
                            .onAppear {
                                self.renderedHeight = contentProxy.size.height
                                self.evaluateEscalation(
                                    header: model.header,
                                    payload: model.payload,
                                    availableHeight: availableHeight
                                )
                            }
                            .onChange(of: contentProxy.size.height) { _, newValue in
                                self.renderedHeight = newValue
                                self.evaluateEscalation(
                                    header: model.header,
                                    payload: model.payload,
                                    availableHeight: availableHeight
                                )
                            }
                    }
                )
                .onChange(of: proxy.size) { _, newSize in
                    let newAvailableHeight = max(newSize.height, 1)
                    self.evaluateEscalation(
                        header: model.header,
                        payload: model.payload,
                        availableHeight: newAvailableHeight
                    )
                }
                .onChange(of: dynamicTypeSize) { _, _ in
                    self.evaluateEscalation(
                        header: model.header,
                        payload: model.payload,
                        availableHeight: availableHeight
                    )
                }
                .alert("全画面表示を推奨", isPresented: $showFullscreenPrompt) {
                    Button("全画面で開く") {
                        Task {
                            await presentationDriver.presentFullscreen(containerID: model.header.containerID)
                        }
                    }
                    Button("この表示で続行", role: .cancel) {
                        EmbeddedStateStore.shared.suppressAutoPrompt(
                            for: model.header.containerID,
                            revision: model.header.presentationHints.contentRevision
                        )
                    }
                } message: {
                    Text("内容が長いため全画面表示の方が見やすくなります。")
                }
        }
    }

    private func evaluateEscalation(
        header: EmbeddedViewHeader,
        payload: DecodedEmbeddedPayload,
        availableHeight: CGFloat
    ) {
        let metrics = payload.metrics
        let renderMetrics = RenderMetrics(
            renderedHeight: renderedHeight,
            availableHeight: availableHeight,
            hasMap: metrics.hasMap,
            listCount: metrics.listCount,
            formFieldCount: metrics.formFieldCount,
            isAccessibilityDynamicType: dynamicTypeSize.isAccessibilitySize,
            isPrimaryActionInitiallyVisible: renderedHeight <= availableHeight * 0.8
        )

        let suppressedRevision = EmbeddedStateStore.shared.suppressedRevision(for: header.containerID)
        let escalation = PresentationEvaluator().evaluate(
            header: header,
            metrics: renderMetrics,
            suppressedRevision: suppressedRevision
        )

        switch escalation {
        case .none:
            return
        case .required:
            Task {
                await presentationDriver.presentFullscreen(containerID: header.containerID)
            }
        case .prompt:
            self.showFullscreenPrompt = true
        }
    }

    private func decodeModel() -> (header: EmbeddedViewHeader, payload: DecodedEmbeddedPayload) {
        if let model {
            return (model.header, model.payload)
        }

        guard let headerJSON, let payloadJSON else {
            let fallbackHeader = EmbeddedViewHeader(
                schemaVersion: "1.0",
                embeddedViewType: EmbeddedViewType.schemaError.rawValue,
                containerID: "schema-error-view",
                title: "表示エラー",
                subtitle: nil,
                riskLevel: "low",
                confirmationStyle: "none",
                presentationHints: UIPresentationHints(contentRevision: "schema-error")
            )
            let fallbackPayload = DecodedEmbeddedPayload.schemaError(
                SchemaErrorPayload(reason: "Missing model and JSON inputs")
            )
            return (fallbackHeader, fallbackPayload)
        }

        do {
            let header = try decoder.decodeHeader(from: headerJSON)
            let payload = try decoder.decodePayload(embeddedViewType: header.embeddedViewType, payloadJSON: payloadJSON)
            return (header, payload)
        } catch {
            let fallbackHeader = EmbeddedViewHeader(
                schemaVersion: "1.0",
                embeddedViewType: EmbeddedViewType.schemaError.rawValue,
                containerID: "schema-error-view",
                title: "表示エラー",
                subtitle: nil,
                riskLevel: "low",
                confirmationStyle: "none",
                presentationHints: UIPresentationHints(contentRevision: "schema-error")
            )
            let fallbackPayload = DecodedEmbeddedPayload.schemaError(
                SchemaErrorPayload(reason: "Schema decode failed: \(error)")
            )
            return (fallbackHeader, fallbackPayload)
        }
    }
}
