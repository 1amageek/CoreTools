import SwiftUI

enum WatchPalette {
    #if canImport(UIKit)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    static let elevated = Color(uiColor: .tertiarySystemGroupedBackground)
    static let outline = Color(uiColor: .separator)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    #else
    static let surface = Color(nsColor: .controlBackgroundColor)
    static let elevated = Color(nsColor: .unemphasizedSelectedContentBackgroundColor)
    static let outline = Color(nsColor: .separatorColor)
    static let secondaryText = Color(nsColor: .secondaryLabelColor)
    #endif
    static let accent = Color.orange
    static let warning = Color.red
}

struct WatchCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(LayoutTokens.regular)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius)
                    .fill(WatchPalette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius)
                    .stroke(WatchPalette.outline, lineWidth: 1)
            )
    }
}

struct WatchSectionTitle: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(WatchPalette.secondaryText)
            .tracking(0.8)
    }
}

struct WatchChip: View {
    let text: String
    var tint: Color = WatchPalette.elevated

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, LayoutTokens.compact)
            .padding(.vertical, 4)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: LayoutTokens.chipRadius))
    }
}
