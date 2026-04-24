#if canImport(ActivityKit) && os(iOS)
import ActivityKit
import CoreTools
import SwiftUI
import WidgetKit

public struct ToolLiveActivityView: View {
    let state: ToolActivityAttributes.ContentState

    public init(state: ToolActivityAttributes.ContentState) {
        self.state = state
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .foregroundStyle(statusColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(state.toolName)
                    .font(.headline)
                Text(statusLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if state.status == .running {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding()
    }

    private var statusIcon: String {
        switch state.status {
        case .running: "gearshape.2"
        case .completed: "checkmark.circle.fill"
        case .failed: "xmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch state.status {
        case .running: .blue
        case .completed: .green
        case .failed: .red
        }
    }

    private var statusLabel: String {
        switch state.status {
        case .running: "Running..."
        case .completed: "Completed"
        case .failed: "Failed"
        }
    }
}

public struct ToolLiveActivityConfiguration: Widget {
    public init() {}

    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: ToolActivityAttributes.self) { context in
            ToolLiveActivityView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "gearshape.2")
                        .foregroundStyle(.blue)
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.toolName)
                            .font(.headline)
                        Text(expandedStatusLabel(for: context.state.status))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.status == .running {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: context.state.status == .completed
                              ? "checkmark.circle.fill"
                              : "xmark.circle.fill")
                        .foregroundStyle(context.state.status == .completed ? .green : .red)
                    }
                }
            } compactLeading: {
                Image(systemName: "gearshape.2")
                    .foregroundStyle(.blue)
            } compactTrailing: {
                Text(context.state.toolName)
                    .lineLimit(1)
                    .font(.caption)
            } minimal: {
                Image(systemName: "gearshape.2")
                    .foregroundStyle(.blue)
            }
        }
    }

    private func expandedStatusLabel(for status: ToolActivityStatus) -> String {
        switch status {
        case .running: "Running..."
        case .completed: "Completed"
        case .failed: "Failed"
        }
    }
}
#endif
