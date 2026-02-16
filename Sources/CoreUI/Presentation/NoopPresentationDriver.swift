public actor NoopPresentationDriver: PresentationDriver {
    public private(set) var presentedContainerIDs: [String]
    public private(set) var dismissedContainerIDs: [String]

    public init() {
        self.presentedContainerIDs = []
        self.dismissedContainerIDs = []
    }

    public func presentFullscreen(containerID: String) async {
        self.presentedContainerIDs.append(containerID)
    }

    public func dismissFullscreen(containerID: String) async {
        self.dismissedContainerIDs.append(containerID)
    }
}
