import SwiftUI

public struct ImagePreviewView: View {
    public let payload: ImagePreviewPayload

    public init(payload: ImagePreviewPayload) {
        self.payload = payload
    }

    public var body: some View {
        WatchCard {
            VStack(alignment: .leading, spacing: LayoutTokens.compact) {
                header

                imageBody
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius)
                            .stroke(WatchPalette.outline, lineWidth: 1)
                    )

                if let title = payload.title {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }

                if let subtitle = payload.subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(WatchPalette.secondaryText)
                        .lineLimit(2)
                }

                if !payload.metadata.isEmpty {
                    metadataGrid
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
        HStack {
            WatchSectionTitle(text: "Photo")
            Spacer()
            WatchChip(text: "確認")
        }
        .foregroundStyle(.white)
    }

    private var metadataGrid: some View {
        let keys = payload.metadata.keys.sorted()

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LayoutTokens.tiny) {
            ForEach(keys, id: \.self) { key in
                if let value = payload.metadata[key] {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(key.uppercased())
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(WatchPalette.secondaryText)
                        Text(value)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .lineLimit(2)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, LayoutTokens.tiny)
                    .padding(.vertical, 6)
                    .background(WatchPalette.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: LayoutTokens.chipRadius))
                }
            }
        }
    }

    @ViewBuilder
    private var imageBody: some View {
        if
            let imageURL = payload.url,
            let url = URL(string: imageURL)
        {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .tint(WatchPalette.accent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.06))
            Image(systemName: payload.placeholder ?? "photo")
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(WatchPalette.secondaryText)
        }
    }
}

#Preview("ImagePreviewView/Watch") {
    ZStack {
        Color.black.ignoresSafeArea()

        ImagePreviewView(
            payload: ImagePreviewPayload(
                url: nil,
                placeholder: "photo.on.rectangle",
                title: "共有前プレビュー",
                subtitle: "位置情報付きで送信",
                metadata: [
                    "撮影日": "2026-02-16",
                    "共有先": "母",
                    "枚数": "1",
                    "場所": "渋谷"
                ]
            )
        )
        .padding(LayoutTokens.compact)
        .frame(maxWidth: .infinity, minHeight: 340)
    }
}
