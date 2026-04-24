/// A type that provides an SF Symbols icon name for display in the UI.
///
/// Tools conforming to this protocol declare which SF Symbol
/// represents their category, enabling the UI to show contextual
/// icons during tool execution.
public protocol ToolIconProviding {
    var iconSystemName: String { get }
}
