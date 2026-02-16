public protocol PresentationDriver: Sendable {
    func presentFullscreen(containerID: String) async
    func dismissFullscreen(containerID: String) async
}
