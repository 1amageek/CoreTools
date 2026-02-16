import SwiftUI

public struct SchemaErrorView: View {
    public let payload: SchemaErrorPayload

    public init(payload: SchemaErrorPayload) {
        self.payload = payload
    }

    public var body: some View {
        WatchCard {
            VStack(alignment: .leading, spacing: LayoutTokens.compact) {
                HStack(spacing: LayoutTokens.tiny) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(WatchPalette.warning)
                    WatchSectionTitle(text: "Schema Error")
                }

                Text(payload.reason)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(4)
                    .textSelection(.enabled)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("SchemaErrorView/Watch") {
    ZStack {
        Color.black.ignoresSafeArea()

        SchemaErrorView(payload: SchemaErrorPayload(reason: "embeddedViewType が未対応です。JSON契約を確認してください。"))
            .padding(LayoutTokens.compact)
            .frame(maxWidth: .infinity, minHeight: 140)
    }
}
