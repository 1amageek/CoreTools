import CoreTools
import SwiftUI

public struct EmbeddedViewModel: Sendable {
    public let document: CoreUIDocument

    public init(document: CoreUIDocument) {
        self.document = document
    }
}

public struct EmbeddedView: View {
    private let model: EmbeddedViewModel?
    private let documentJSON: String?
    private let legacyHeaderJSON: String?
    private let legacyPayloadJSON: String?
    private let containerID: String
    private let actionHandler: EmbeddedViewActionHandler
    private let presentationDriver: PresentationDriver
    private let decoder: SchemaDecoder
    private let registry: ScreenRegistry

    @State private var renderedHeight: CGFloat = 0
    @State private var actionStatusByViewID: [String: String] = [:]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(
        model: EmbeddedViewModel,
        actionHandler: EmbeddedViewActionHandler,
        presentationDriver: PresentationDriver,
        containerID: String = UUID().uuidString,
        registry: ScreenRegistry = ScreenRegistry()
    ) {
        self.model = model
        self.documentJSON = nil
        self.legacyHeaderJSON = nil
        self.legacyPayloadJSON = nil
        self.containerID = containerID
        self.actionHandler = actionHandler
        self.presentationDriver = presentationDriver
        self.decoder = SchemaDecoder()
        self.registry = registry
    }

    public init(
        documentJSON: String,
        actionHandler: EmbeddedViewActionHandler,
        presentationDriver: PresentationDriver,
        containerID: String = UUID().uuidString,
        decoder: SchemaDecoder = SchemaDecoder(),
        registry: ScreenRegistry = ScreenRegistry()
    ) {
        self.model = nil
        self.documentJSON = documentJSON
        self.legacyHeaderJSON = nil
        self.legacyPayloadJSON = nil
        self.containerID = containerID
        self.actionHandler = actionHandler
        self.presentationDriver = presentationDriver
        self.decoder = decoder
        self.registry = registry
    }

    public init(
        headerJSON: String,
        payloadJSON: String,
        actionHandler: EmbeddedViewActionHandler,
        presentationDriver: PresentationDriver,
        containerID: String = UUID().uuidString,
        decoder: SchemaDecoder = SchemaDecoder(),
        registry: ScreenRegistry = ScreenRegistry()
    ) {
        self.model = nil
        self.documentJSON = nil
        self.legacyHeaderJSON = headerJSON
        self.legacyPayloadJSON = payloadJSON
        self.containerID = containerID
        self.actionHandler = actionHandler
        self.presentationDriver = presentationDriver
        self.decoder = decoder
        self.registry = registry
    }

    public var body: some View {
        GeometryReader { proxy in
            let document = decodeDocument()
            let availableHeight = max(proxy.size.height, 1)

            ScrollView {
                VStack(alignment: .leading, spacing: LayoutTokens.compact) {
                    Text(document.message)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let ui = document.ui {
                        layoutedViews(ui)

                        if ui.actions.contains(where: { $0.type != .fullscreen }) {
                            actionBar(actions: ui.actions, scopeID: "ui")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(LayoutTokens.compact)
                .background(
                    GeometryReader { contentProxy in
                        Color.clear
                            .onAppear {
                                self.renderedHeight = contentProxy.size.height
                                self.evaluateEscalation(document: document, availableHeight: availableHeight)
                            }
                            .onChange(of: contentProxy.size.height) { _, newValue in
                                self.renderedHeight = newValue
                                self.evaluateEscalation(document: document, availableHeight: availableHeight)
                            }
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onChange(of: proxy.size) { _, newSize in
                let newAvailableHeight = max(newSize.height, 1)
                self.evaluateEscalation(document: document, availableHeight: newAvailableHeight)
            }
            .onChange(of: dynamicTypeSize) { _, _ in
                self.evaluateEscalation(document: document, availableHeight: availableHeight)
            }
        }
    }

    @ViewBuilder
    private func layoutedViews(_ ui: CoreUIDocumentUI) -> some View {
        if ui.layout == .horizontal {
            HStack(alignment: .top, spacing: LayoutTokens.compact) {
                ForEach(ui.views) { item in
                    renderedView(item)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: LayoutTokens.compact) {
                ForEach(ui.views) { item in
                    renderedView(item)
                }
            }
        }
    }

    private func renderedView(_ item: CoreUIViewItem) -> some View {
        VStack(alignment: .leading, spacing: LayoutTokens.tiny) {
            registry
                .render(payload: item.payload)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    Task {
                        await presentationDriver.presentFullscreen(containerID: containerID)
                    }
                }

            if item.actions.contains(where: { $0.type != .fullscreen }) {
                actionBar(actions: item.actions, scopeID: item.id)
            }

            if let status = actionStatusByViewID[item.id] {
                Text(status)
                    .font(.footnote)
                    .foregroundStyle(WatchPalette.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func actionBar(actions: [CoreUIAction], scopeID: String) -> some View {
        let visibleActions = actions.filter { $0.type != .fullscreen }

        return Group {
            if !visibleActions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: LayoutTokens.tiny) {
                        ForEach(Array(visibleActions.enumerated()), id: \.offset) { _, action in
                            Button(action.label) {
                                handleAction(action, scopeID: scopeID)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func handleAction(_ action: CoreUIAction, scopeID: String) {
        switch action.type {
        case .fullscreen:
            Task {
                await presentationDriver.presentFullscreen(containerID: containerID)
            }
        case .dismiss:
            Task {
                await presentationDriver.dismissFullscreen(containerID: containerID)
            }
        case .tool:
            guard let name = action.name else {
                actionStatusByViewID[scopeID] = "tool name is missing"
                return
            }

            let argumentsJSON: String?
            if let input = action.input {
                do {
                    let data = try JSONEncoder().encode(input)
                    argumentsJSON = String(data: data, encoding: .utf8)
                } catch {
                    argumentsJSON = nil
                }
            } else {
                argumentsJSON = nil
            }

            let descriptor = UIActionDescriptor(
                actionType: UIActionType.executeTool.rawValue,
                actionID: scopeID,
                toolName: name,
                argumentsJSON: argumentsJSON
            )

            Task {
                let outcome = await actionHandler.handle(containerID: containerID, action: descriptor)
                await MainActor.run {
                    actionStatusByViewID[scopeID] = outcome.message
                }
            }
        }
    }

    private func evaluateEscalation(document: CoreUIDocument, availableHeight: CGFloat) {
        guard let ui = document.ui else {
            return
        }

        let merged = ui.views.map(\.payload.metrics)
        let hasMap = merged.contains { $0.hasMap }
        let listCount = merged.reduce(0) { $0 + $1.listCount }
        let formFieldCount = merged.reduce(0) { $0 + $1.formFieldCount }

        let renderMetrics = RenderMetrics(
            renderedHeight: renderedHeight,
            availableHeight: availableHeight,
            hasMap: hasMap,
            listCount: listCount,
            formFieldCount: formFieldCount,
            isAccessibilityDynamicType: dynamicTypeSize.isAccessibilitySize,
            isPrimaryActionInitiallyVisible: renderedHeight <= availableHeight * 0.8
        )

        let syntheticHeader = EmbeddedViewHeader(
            schemaVersion: "1.0",
            embeddedViewType: EmbeddedViewType.loadingState.rawValue,
            containerID: containerID,
            title: document.message,
            riskLevel: "low",
            confirmationStyle: UIConfirmationStyle.none.rawValue,
            presentationHints: UIPresentationHints(contentRevision: escalationRevision(document: document))
        )

        let suppressedRevision = EmbeddedStateStore.shared.suppressedRevision(for: containerID)
        let escalation = PresentationEvaluator().evaluate(
            header: syntheticHeader,
            metrics: renderMetrics,
            suppressedRevision: suppressedRevision
        )

        switch escalation {
        case .none:
            return
        case .required:
            Task {
                await presentationDriver.presentFullscreen(containerID: containerID)
            }
        case .prompt:
            return
        }
    }

    private func escalationRevision(document: CoreUIDocument) -> String {
        let viewCount = document.ui?.views.count ?? 0
        return "\(document.schemaVersion)-\(viewCount)-\(document.message.count)"
    }

    private func decodeDocument() -> CoreUIDocument {
        if let model {
            return model.document
        }

        if let documentJSON {
            do {
                return try decoder.decodeDocument(from: documentJSON)
            } catch {
                return fallbackDocument(reason: "Schema decode failed: \(error)")
            }
        }

        guard let legacyHeaderJSON, let legacyPayloadJSON else {
            return fallbackDocument(reason: "Missing JSON inputs")
        }

        do {
            let header = try decoder.decodeHeader(from: legacyHeaderJSON)
            let payload = try decoder.decodePayload(
                embeddedViewType: header.embeddedViewType,
                payloadJSON: legacyPayloadJSON
            )

            let view = CoreUIViewItem(
                id: "legacy-view-0",
                kind: payload.kind,
                payload: payload,
                actions: []
            )

            return CoreUIDocument(
                schemaVersion: "1.1",
                message: header.title,
                ui: CoreUIDocumentUI(layout: .vertical, views: [view], actions: [])
            )
        } catch {
            return fallbackDocument(reason: "Legacy schema decode failed: \(error)")
        }
    }

    private func fallbackDocument(reason: String) -> CoreUIDocument {
        let view = CoreUIViewItem(
            id: "schema-error",
            kind: .schemaError,
            payload: .schemaError(SchemaErrorPayload(reason: reason)),
            actions: []
        )

        return CoreUIDocument(
            schemaVersion: "1.1",
            message: "表示エラー",
            ui: CoreUIDocumentUI(layout: .vertical, views: [view], actions: [])
        )
    }
}
