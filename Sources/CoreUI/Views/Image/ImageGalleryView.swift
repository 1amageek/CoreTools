import SwiftUI

struct ImageGalleryView: View {
    let payload: ImageGalleryPayload

    @State private var selectedItem: ImageGalleryItem?

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.compact) {
            WatchSectionTitle(text: "Photos")
                .padding(.leading, LayoutTokens.regular)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: LayoutTokens.compact) {
                    ForEach(payload.images) { item in
                        ImageCardView(item: item)
                            .onTapGesture { selectedItem = item }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, LayoutTokens.regular, for: .scrollContent)
        }
        .sheet(item: $selectedItem) { item in
            ImageDetailSheet(item: item)
        }
    }
}

// MARK: - Card

private struct ImageCardView: View {
    let item: ImageGalleryItem

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.tiny) {
            asyncImage
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius)
                        .stroke(WatchPalette.outline, lineWidth: 1)
                )

            if let title = item.title {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .lineLimit(2)
            }

            if let caption = item.caption {
                Text(caption)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(WatchPalette.secondaryText)
                    .lineLimit(2)
            }
        }
        .frame(width: 150)
    }

    @ViewBuilder
    private var asyncImage: some View {
        if let url = URL(string: item.url) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(WatchPalette.elevated)
                        ProgressView().tint(WatchPalette.accent)
                    }
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
            Rectangle().fill(WatchPalette.elevated)
            Image(systemName: "photo")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(WatchPalette.secondaryText)
        }
    }
}

// MARK: - Detail Sheet

private struct ImageDetailSheet: View {
    let item: ImageGalleryItem

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: LayoutTokens.regular) {
                        fullImage
                            .frame(maxWidth: geometry.size.width)
                            .frame(minHeight: geometry.size.width * 0.75)

                        if item.title != nil || item.caption != nil {
                            VStack(alignment: .leading, spacing: LayoutTokens.tiny) {
                                if let title = item.title {
                                    Text(title)
                                        .font(.headline)
                                }
                                if let caption = item.caption {
                                    Text(caption)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private var fullImage: some View {
        if let url = URL(string: item.url) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .tint(WatchPalette.accent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    ContentUnavailableView("Failed to load image", systemImage: "photo.badge.exclamationmark")
                @unknown default:
                    ContentUnavailableView("Failed to load image", systemImage: "photo.badge.exclamationmark")
                }
            }
        } else {
            ContentUnavailableView("Invalid URL", systemImage: "photo.badge.exclamationmark")
        }
    }
}

// MARK: - Preview

#Preview {
    ImageGalleryView(payload: ImageGalleryPayload(images: [
        ImageGalleryItem(id: "1", url: "https://picsum.photos/id/10/300/300", title: "Mountain View", caption: "A beautiful mountain landscape"),
        ImageGalleryItem(id: "2", url: "https://picsum.photos/id/20/300/300", title: "Ocean"),
        ImageGalleryItem(id: "3", url: "https://picsum.photos/id/30/300/300"),
    ]))
    .frame(width: 400)
}
