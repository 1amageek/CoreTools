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

    @State private var containerHeight: CGFloat = 0

    public var body: some View {
        let document = decodeDocument()

        VStack(alignment: .leading, spacing: LayoutTokens.compact) {
            if let ui = document.ui {
                renderNode(ui.body)
            } else {
                Text(document.message)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            GeometryReader { contentProxy in
                Color.clear
                    .onAppear {
                        self.renderedHeight = contentProxy.size.height
                        self.evaluateEscalation(document: document, availableHeight: containerHeight)
                    }
                    .onChange(of: contentProxy.size.height) { _, newValue in
                        self.renderedHeight = newValue
                        self.evaluateEscalation(document: document, availableHeight: containerHeight)
                    }
            }
        )
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { newValue in
            containerHeight = newValue
            evaluateEscalation(document: document, availableHeight: newValue)
        }
        .onChange(of: dynamicTypeSize) { _, _ in
            self.evaluateEscalation(document: document, availableHeight: containerHeight)
        }
    }

    private func renderNode(_ node: CoreUINode) -> AnyView {
        switch node {
        case .vstack(let stack):
            return AnyView(VStack(alignment: .leading, spacing: spacingValue(stack.spacing)) {
                ForEach(Array(stack.content.enumerated()), id: \.offset) { _, child in
                    renderNode(child)
                }
            })
        case .hstack(let stack):
            return AnyView(HStack(alignment: .top, spacing: spacingValue(stack.spacing)) {
                ForEach(Array(stack.content.enumerated()), id: \.offset) { _, child in
                    renderNode(child)
                }
            })
        case .section(let section):
            return AnyView(VStack(alignment: .leading, spacing: LayoutTokens.tiny) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .font(.headline)
                    if let subtitle = section.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(WatchPalette.secondaryText)
                    }
                }

                VStack(alignment: .leading, spacing: LayoutTokens.compact) {
                    ForEach(Array(section.content.enumerated()), id: \.offset) { _, child in
                        renderNode(child)
                    }
                }
            })
        case .view(let item):
            return AnyView(renderedView(item))
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
        case .invoke:
            guard let target = action.target else {
                actionStatusByViewID[scopeID] = "action target is missing"
                return
            }

            guard target.kind == "tool" else {
                actionStatusByViewID[scopeID] = "unsupported action target: \(target.kind)"
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
                toolName: target.name,
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

        let merged = ui.leafViews.map(\.payload.metrics)
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
        let viewCount = document.ui?.leafViews.count ?? 0
        return "\(document.schema)-\(viewCount)-\(document.message.count)"
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
                type: type(for: payload),
                state: .content,
                data: payload,
                actions: []
            )

            return CoreUIDocument(
                schema: "coreui/1",
                message: header.title,
                ui: CoreUIDocumentUI(body: .view(view))
            )
        } catch {
            return fallbackDocument(reason: "Legacy schema decode failed: \(error)")
        }
    }

    private func fallbackDocument(reason: String) -> CoreUIDocument {
        let view = CoreUIViewItem(
            id: "schema-error",
            type: .systemError,
            state: .error,
            data: .schemaError(SchemaErrorPayload(reason: reason)),
            actions: []
        )

        return CoreUIDocument(
            schema: "coreui/1",
            message: "表示エラー",
            ui: CoreUIDocumentUI(body: .view(view))
        )
    }

    private func spacingValue(_ spacing: CoreUISpacing?) -> CGFloat {
        switch spacing {
        case .tight:
            return LayoutTokens.tiny
        case .compact:
            return LayoutTokens.compact
        case .regular:
            return LayoutTokens.regular
        case .spacious:
            return LayoutTokens.spacious
        case nil:
            return LayoutTokens.compact
        }
    }

    private func type(for payload: DecodedEmbeddedPayload) -> CoreUIViewType {
        switch payload {
        case .mapSnapshot:
            return .mapSnapshot
        case .mapRoute:
            return .mapRoute
        case .imagePreview:
            return .imagePreview
        case .imageGallery:
            return .imageGallery
        case .calendarTimeline:
            return .calendarTimeline
        case .healthTrend:
            return .healthTrend
        case .placeList:
            return .placesList
        case .schemaError:
            return .systemError
        case .loadingState:
            return .systemLoading
        }
    }
}
