import Testing
@testable import CoreUI

@MainActor
@Test func sameContainerIDSharesSingleStateObject() async throws {
    let store = EmbeddedStateStore(defaultTTL: 60)

    let embeddedState = store.state(for: "container-1")
    embeddedState.updateTextInput(key: "note", value: "from-view")

    let fullscreenState = store.state(for: "container-1")

    #expect(embeddedState === fullscreenState)
    #expect(fullscreenState.textInputs["note"] == "from-view")
}

@MainActor
@Test func differentContainerIDsAreIsolated() async throws {
    let store = EmbeddedStateStore(defaultTTL: 60)

    let first = store.state(for: "container-1")
    first.updateTextInput(key: "note", value: "first")

    let second = store.state(for: "container-2")
    #expect(second.textInputs["note"] == nil)
}
