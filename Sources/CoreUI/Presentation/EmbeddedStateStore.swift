import Foundation

@MainActor
public final class EmbeddedStateStore {
    public static let shared = EmbeddedStateStore()

    public let defaultTTL: TimeInterval
    private var states: [String: EmbeddedState]

    public init(defaultTTL: TimeInterval = 24 * 60 * 60) {
        self.defaultTTL = defaultTTL
        self.states = [:]
    }

    public func state(for containerID: String, now: Date = Date()) -> EmbeddedState {
        self.cleanupExpired(now: now)
        if let state = self.states[containerID] {
            return state
        }

        let state = EmbeddedState(containerID: containerID, now: now)
        self.states[containerID] = state
        return state
    }

    public func suppressAutoPrompt(
        for containerID: String,
        revision: String,
        now: Date = Date()
    ) {
        let state = self.state(for: containerID, now: now)
        state.suppressAutoPrompt(revision: revision, now: now)
    }

    public func suppressedRevision(for containerID: String, now: Date = Date()) -> String? {
        let state = self.state(for: containerID, now: now)
        return state.suppressedRevision
    }

    public func cleanupExpired(now: Date = Date()) {
        self.states = self.states.filter { _, state in
            now.timeIntervalSince(state.lastUpdatedAt) <= self.defaultTTL
        }
    }
}
