import Testing
@testable import CoreUI

@Test func manualFullscreenDriverTracksOpenAndClose() async throws {
    let driver = NoopPresentationDriver()

    await driver.presentFullscreen(containerID: "container-1")
    await driver.dismissFullscreen(containerID: "container-1")

    let opened = await driver.presentedContainerIDs
    let closed = await driver.dismissedContainerIDs

    #expect(opened == ["container-1"])
    #expect(closed == ["container-1"])
}
