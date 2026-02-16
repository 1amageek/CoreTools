import Foundation
import Observation

@Observable
@MainActor
public final class EmbeddedState {
    public let containerID: String
    public var textInputs: [String: String]
    public var selectedValues: [String: [String]]
    public var confirmationStep: Int
    public var scrollOffset: Double
    public var suppressedRevision: String?
    public private(set) var lastUpdatedAt: Date

    public init(containerID: String, now: Date = Date()) {
        self.containerID = containerID
        self.textInputs = [:]
        self.selectedValues = [:]
        self.confirmationStep = 0
        self.scrollOffset = 0
        self.suppressedRevision = nil
        self.lastUpdatedAt = now
    }

    public func updateTextInput(key: String, value: String, now: Date = Date()) {
        self.textInputs[key] = value
        self.lastUpdatedAt = now
    }

    public func updateSelection(key: String, value: [String], now: Date = Date()) {
        self.selectedValues[key] = value
        self.lastUpdatedAt = now
    }

    public func updateConfirmationStep(_ step: Int, now: Date = Date()) {
        self.confirmationStep = step
        self.lastUpdatedAt = now
    }

    public func updateScrollOffset(_ offset: Double, now: Date = Date()) {
        self.scrollOffset = offset
        self.lastUpdatedAt = now
    }

    public func suppressAutoPrompt(revision: String, now: Date = Date()) {
        self.suppressedRevision = revision
        self.lastUpdatedAt = now
    }
}
