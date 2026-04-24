import SwiftUI

/// A capsule-shaped indicator displayed beside the Dynamic Island
/// showing an activity spinner and the current tool's category icon.
public struct AgentActivityIndicator: View {

    @State private var animateGradient = false
    private let iconSystemName: String?

    /// - Parameter iconSystemName: The SF Symbol name to display.
    ///   Pass `nil` to hide the indicator.
    public init(iconSystemName: String?) {
        self.iconSystemName = iconSystemName
    }

    public var body: some View {
        if let iconSystemName {
            Image(systemName: iconSystemName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    AngularGradient(
                        colors: [.purple, .cyan, .blue, .purple],
                        center: .center,
                        angle: .degrees(animateGradient ? 360 : 0)
                    )
                )
                .padding(.horizontal, 8)
                .frame(height: 37)
                .background(.black, in: Capsule())
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        animateGradient = true
                    }
                }
        }
    }
}

#Preview("Location") {
    AgentActivityIndicator(iconSystemName: "location.fill")
        .padding()
}

#Preview("Map") {
    AgentActivityIndicator(iconSystemName: "map.fill")
        .padding()
}

#Preview("Default") {
    AgentActivityIndicator(iconSystemName: "gearshape.2.fill")
        .padding()
}

#Preview("Hidden") {
    AgentActivityIndicator(iconSystemName: nil)
        .padding()
}
