import SwiftUI

public struct LoadingStateView: View {
    public let payload: LoadingStatePayload

    public init(payload: LoadingStatePayload) {
        self.payload = payload
    }

    public var body: some View {
        WatchCard {
            VStack(alignment: .leading, spacing: LayoutTokens.compact) {
                WatchSectionTitle(text: "Loading")

                HStack(spacing: LayoutTokens.compact) {
                    ProgressView()
                        .tint(WatchPalette.accent)
                        .controlSize(.regular)

                    Text(payload.message)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("LoadingStateView/Watch") {
    ZStack {
        Color.black.ignoresSafeArea()

        LoadingStateView(payload: LoadingStatePayload(message: "地図を準備しています…"))
            .padding(LayoutTokens.compact)
            .frame(maxWidth: .infinity, minHeight: 120)
    }
}
