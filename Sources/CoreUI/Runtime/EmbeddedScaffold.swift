import CoreTools
import SwiftUI

public struct EmbeddedScaffold<Content: View>: View {
    private let header: EmbeddedViewHeader
    private var state: EmbeddedState
    private let actionHandler: EmbeddedViewActionHandler
    private let presentationDriver: PresentationDriver
    private let content: Content

    public init(
        header: EmbeddedViewHeader,
        state: EmbeddedState,
        actionHandler: EmbeddedViewActionHandler,
        presentationDriver: PresentationDriver,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.state = state
        self.actionHandler = actionHandler
        self.presentationDriver = presentationDriver
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.compact) {
            HStack(alignment: .top, spacing: LayoutTokens.tiny) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(header.title)
                        .font(.headline)
                    if let subtitle = header.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if header.presentationHints.fullscreenAllowed {
                    Button("全画面で開く") {
                        Task {
                            await presentationDriver.presentFullscreen(containerID: header.containerID)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            if state.confirmationStep > 0 {
                Text("最終確認: もう一度実行すると処理が確定します。")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }

            if let resultSummary = state.textInputs["result_summary"] {
                Text(resultSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: LayoutTokens.tiny) {
                if let secondary = header.secondaryAction {
                    Button("キャンセル") {
                        Task {
                            let outcome = await actionHandler.handle(containerID: header.containerID, action: secondary)
                            state.updateTextInput(
                                key: "result_summary",
                                value: outcome.message
                            )
                        }
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                if let primary = header.primaryAction {
                    Button("実行") {
                        self.runPrimaryAction(primary)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(LayoutTokens.regular)
        .background(
            RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius)
                .fill(Color.secondary.opacity(LayoutTokens.mutedSurfaceOpacity))
        )
    }

    private func runPrimaryAction(_ action: UIActionDescriptor) {
        let confirmation = UIConfirmationStyle(rawValue: header.confirmationStyle) ?? .single

        if confirmation == .double && state.confirmationStep == 0 {
            state.updateConfirmationStep(1)
            return
        }

        state.updateConfirmationStep(0)

        Task {
            let outcome = await actionHandler.handle(containerID: header.containerID, action: action)
            state.updateTextInput(
                key: "result_summary",
                value: outcome.message
            )
        }
    }
}
