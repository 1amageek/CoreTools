import Foundation

struct ViewDocumentContract {
    struct NormalizationResult: Sendable {
        let documentJSON: String
        let warnings: [String]
        let normalized: Bool
    }

    private static let schema = "coreui/1"
    private static let nodeKeys: Set<String> = ["vstack", "hstack", "section", "view"]
    private static let supportedTypes: Set<String> = [
        "map.snapshot",
        "map.route",
        "image.preview",
        "image.gallery",
        "calendar.timeline",
        "health.trend",
        "places.list",
        "system.loading",
        "system.error",
    ]
    private static let supportedStates: Set<String> = [
        "content",
        "empty",
        "loading",
        "error",
        "permissionRequired",
        "partial",
    ]
    private static let supportedSpacing: Set<String> = ["tight", "compact", "regular", "spacious"]
    private static let supportedActionTypes: Set<String> = ["invoke", "fullscreen", "dismiss"]

    static func normalize(documentJSON: String) throws -> NormalizationResult {
        var root = try parseJSONObject(from: documentJSON, parameter: "documentJSON")
        var warnings: [String] = []
        var normalized = false
        var generatedViewIndex = 0

        normalized = enforceSchema(&root, warnings: &warnings) || normalized
        normalized = enforceMessage(&root, warnings: &warnings) || normalized

        if let rawUI = root["ui"] as? [String: Any] {
            var ui = rawUI
            if let rawBody = ui["body"] {
                ui["body"] = normalizeNode(
                    rawBody,
                    path: "ui.body",
                    warnings: &warnings,
                    generatedViewIndex: &generatedViewIndex
                )
            } else {
                ui["body"] = fallbackNode(
                    id: nextViewID(&generatedViewIndex),
                    reason: "ui.body is required"
                )
                warnings.append("ui.body was missing and replaced with system.error")
            }
            root["ui"] = ui
            normalized = true
        } else if root["ui"] != nil {
            root.removeValue(forKey: "ui")
            warnings.append("ui was not an object and was removed")
            normalized = true
        }

        let encoded = try JSONSerialization.data(withJSONObject: root, options: [.sortedKeys])
        return NormalizationResult(
            documentJSON: String(decoding: encoded, as: UTF8.self),
            warnings: warnings,
            normalized: normalized || !warnings.isEmpty
        )
    }

    static func validate(documentJSON: String) -> [ViewValidationIssue] {
        do {
            let root = try parseJSONObject(from: documentJSON, parameter: "documentJSON")
            var issues: [ViewValidationIssue] = []
            validateRoot(root, issues: &issues)
            return issues
        } catch {
            return [
                ViewValidationIssue(path: "$", reason: "documentJSON must be a JSON object: \(error)")
            ]
        }
    }

    private static func parseJSONObject(from json: String, parameter: String) throws -> [String: Any] {
        let data = Data(json.utf8)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let root = object as? [String: Any] else {
            throw ViewDocumentError.invalidJSONObject(parameter)
        }
        return root
    }

    private static func enforceSchema(
        _ root: inout [String: Any],
        warnings: inout [String]
    ) -> Bool {
        guard let value = root["schema"] as? String else {
            root["schema"] = schema
            warnings.append("schema was missing and set to \(schema)")
            return true
        }

        guard value == schema else {
            root["schema"] = schema
            warnings.append("schema '\(value)' is unsupported and was replaced with \(schema)")
            return true
        }

        return false
    }

    private static func enforceMessage(
        _ root: inout [String: Any],
        warnings: inout [String]
    ) -> Bool {
        guard let message = root["message"] as? String, !message.isEmpty else {
            root["message"] = ""
            warnings.append("message was missing or invalid and set to an empty string")
            return true
        }
        return false
    }

    private static func normalizeNode(
        _ rawNode: Any,
        path: String,
        warnings: inout [String],
        generatedViewIndex: inout Int
    ) -> [String: Any] {
        guard let node = rawNode as? [String: Any] else {
            warnings.append("\(path) is not an object and was replaced with system.error")
            return fallbackNode(id: nextViewID(&generatedViewIndex), reason: "\(path) is not an object")
        }

        let presentNodeKeys = node.keys.filter { nodeKeys.contains($0) }
        guard let selectedKey = presentNodeKeys.first else {
            warnings.append("\(path) has no renderable node key and was replaced with system.error")
            return fallbackNode(id: nextViewID(&generatedViewIndex), reason: "\(path) has no node key")
        }

        if presentNodeKeys.count > 1 {
            warnings.append("\(path) had multiple node keys; '\(selectedKey)' was kept")
        }

        switch selectedKey {
        case "vstack", "hstack":
            return [
                selectedKey: normalizeStack(
                    node[selectedKey] as Any,
                    path: "\(path).\(selectedKey)",
                    warnings: &warnings,
                    generatedViewIndex: &generatedViewIndex
                )
            ]
        case "section":
            return [
                "section": normalizeSection(
                    node[selectedKey] as Any,
                    path: "\(path).section",
                    warnings: &warnings,
                    generatedViewIndex: &generatedViewIndex
                )
            ]
        default:
            return [
                "view": normalizeView(
                    node[selectedKey] as Any,
                    path: "\(path).view",
                    warnings: &warnings,
                    generatedViewIndex: &generatedViewIndex
                )
            ]
        }
    }

    private static func normalizeStack(
        _ rawStack: Any,
        path: String,
        warnings: inout [String],
        generatedViewIndex: inout Int
    ) -> [String: Any] {
        guard var stack = rawStack as? [String: Any] else {
            warnings.append("\(path) is not an object and was replaced with system.error content")
            return [
                "content": [
                    fallbackNode(id: nextViewID(&generatedViewIndex), reason: "\(path) is not an object")
                ]
            ]
        }

        if let spacing = stack["spacing"] as? String {
            if !supportedSpacing.contains(spacing) {
                stack["spacing"] = "regular"
                warnings.append("\(path).spacing '\(spacing)' is unsupported and was replaced with 'regular'")
            }
        }

        stack["content"] = normalizeContent(
            stack["content"],
            path: "\(path).content",
            warnings: &warnings,
            generatedViewIndex: &generatedViewIndex
        )
        return stack
    }

    private static func normalizeSection(
        _ rawSection: Any,
        path: String,
        warnings: inout [String],
        generatedViewIndex: inout Int
    ) -> [String: Any] {
        guard var section = rawSection as? [String: Any] else {
            warnings.append("\(path) is not an object and was replaced with a system error section")
            return [
                "title": "Error",
                "content": [
                    fallbackNode(id: nextViewID(&generatedViewIndex), reason: "\(path) is not an object")
                ]
            ]
        }

        if section["title"] as? String == nil {
            section["title"] = "Section"
            warnings.append("\(path).title was missing and set to 'Section'")
        }

        stackContentToSectionContent(&section)
        section["content"] = normalizeContent(
            section["content"],
            path: "\(path).content",
            warnings: &warnings,
            generatedViewIndex: &generatedViewIndex
        )
        return section
    }

    private static func normalizeView(
        _ rawView: Any,
        path: String,
        warnings: inout [String],
        generatedViewIndex: inout Int
    ) -> [String: Any] {
        guard var view = rawView as? [String: Any] else {
            warnings.append("\(path) is not an object and was replaced with system.error")
            return fallbackView(id: nextViewID(&generatedViewIndex), reason: "\(path) is not an object")
        }

        let viewID: String
        if let id = view["id"] as? String, !id.isEmpty {
            viewID = id
        } else {
            viewID = nextViewID(&generatedViewIndex)
            view["id"] = viewID
            warnings.append("\(path).id was missing and set to \(viewID)")
        }

        guard let type = view["type"] as? String, supportedTypes.contains(type) else {
            let value = view["type"] as? String ?? "<missing>"
            warnings.append("\(path).type '\(value)' is unsupported and was replaced with system.error")
            return fallbackView(id: viewID, reason: "unsupported type: \(value)")
        }

        if let state = view["state"] as? String {
            if !supportedStates.contains(state) {
                view["state"] = "content"
                warnings.append("\(path).state '\(state)' is unsupported and was replaced with 'content'")
            }
        } else {
            view["state"] = "content"
            warnings.append("\(path).state was missing and set to 'content'")
        }

        guard view["data"] is [String: Any] else {
            warnings.append("\(path).data is missing or invalid and was replaced with system.error")
            return fallbackView(id: viewID, reason: "data is missing or invalid")
        }

        if let actionsAny = view["actions"] {
            let actions = normalizeActions(actionsAny, path: "\(path).actions", warnings: &warnings)
            if actions.isEmpty {
                view.removeValue(forKey: "actions")
            } else {
                view["actions"] = actions
            }
        }

        return view
    }

    private static func normalizeContent(
        _ rawContent: Any?,
        path: String,
        warnings: inout [String],
        generatedViewIndex: inout Int
    ) -> [[String: Any]] {
        guard let content = rawContent as? [Any], !content.isEmpty else {
            warnings.append("\(path) was missing or empty and was replaced with system.error")
            return [
                fallbackNode(id: nextViewID(&generatedViewIndex), reason: "\(path) was missing or empty")
            ]
        }

        return content.map {
            normalizeNode(
                $0,
                path: "\(path)[]",
                warnings: &warnings,
                generatedViewIndex: &generatedViewIndex
            )
        }
    }

    private static func normalizeActions(
        _ rawActions: Any,
        path: String,
        warnings: inout [String]
    ) -> [[String: Any]] {
        guard let items = rawActions as? [Any] else {
            warnings.append("\(path) is not an array and was removed")
            return []
        }

        var actions: [[String: Any]] = []
        for (index, item) in items.enumerated() {
            guard let action = item as? [String: Any] else {
                warnings.append("\(path)[\(index)] is not an object and was removed")
                continue
            }

            guard let type = action["type"] as? String, supportedActionTypes.contains(type) else {
                warnings.append("\(path)[\(index)].type is missing or unsupported and was removed")
                continue
            }

            guard action["label"] is String else {
                warnings.append("\(path)[\(index)].label is missing and action was removed")
                continue
            }

            if type == "invoke" {
                guard action["target"] is [String: Any] else {
                    warnings.append("\(path)[\(index)].target is required for invoke and action was removed")
                    continue
                }
            }

            actions.append(action)
        }

        return actions
    }

    private static func fallbackNode(id: String, reason: String) -> [String: Any] {
        ["view": fallbackView(id: id, reason: reason)]
    }

    private static func fallbackView(id: String, reason: String) -> [String: Any] {
        [
            "id": id,
            "type": "system.error",
            "state": "error",
            "data": ["reason": reason],
        ]
    }

    private static func nextViewID(_ index: inout Int) -> String {
        let id = "view-\(index)"
        index += 1
        return id
    }

    private static func stackContentToSectionContent(_ section: inout [String: Any]) {
        if section["content"] == nil, let child = section["body"] {
            section["content"] = [child]
        }
    }

    private static func validateRoot(_ root: [String: Any], issues: inout [ViewValidationIssue]) {
        guard let schemaValue = root["schema"] as? String else {
            issues.append(.init(path: "$.schema", reason: "schema is required"))
            return
        }

        guard schemaValue == schema else {
            issues.append(.init(path: "$.schema", reason: "schema must be '\(schema)'"))
            return
        }

        if root["message"] as? String == nil {
            issues.append(.init(path: "$.message", reason: "message is required"))
        }

        guard let ui = root["ui"] else {
            return
        }

        guard let uiObject = ui as? [String: Any] else {
            issues.append(.init(path: "$.ui", reason: "ui must be an object"))
            return
        }

        guard let body = uiObject["body"] else {
            issues.append(.init(path: "$.ui.body", reason: "body is required when ui is present"))
            return
        }

        validateNode(body, path: "$.ui.body", issues: &issues)
    }

    private static func validateNode(_ rawNode: Any, path: String, issues: inout [ViewValidationIssue]) {
        guard let node = rawNode as? [String: Any] else {
            issues.append(.init(path: path, reason: "node must be an object"))
            return
        }

        let presentNodeKeys = node.keys.filter { nodeKeys.contains($0) }
        guard presentNodeKeys.count == 1, let key = presentNodeKeys.first else {
            issues.append(.init(path: path, reason: "node must contain exactly one of vstack, hstack, section, or view"))
            return
        }

        switch key {
        case "vstack", "hstack":
            validateStack(node[key] as Any, path: "\(path).\(key)", issues: &issues)
        case "section":
            validateSection(node[key] as Any, path: "\(path).section", issues: &issues)
        default:
            validateView(node[key] as Any, path: "\(path).view", issues: &issues)
        }
    }

    private static func validateStack(_ rawStack: Any, path: String, issues: inout [ViewValidationIssue]) {
        guard let stack = rawStack as? [String: Any] else {
            issues.append(.init(path: path, reason: "stack must be an object"))
            return
        }

        if let spacing = stack["spacing"] as? String, !supportedSpacing.contains(spacing) {
            issues.append(.init(path: "\(path).spacing", reason: "unsupported spacing '\(spacing)'"))
        }

        validateContent(stack["content"], path: "\(path).content", issues: &issues)
    }

    private static func validateSection(_ rawSection: Any, path: String, issues: inout [ViewValidationIssue]) {
        guard let section = rawSection as? [String: Any] else {
            issues.append(.init(path: path, reason: "section must be an object"))
            return
        }

        if section["title"] as? String == nil {
            issues.append(.init(path: "\(path).title", reason: "title is required"))
        }

        validateContent(section["content"], path: "\(path).content", issues: &issues)
    }

    private static func validateContent(_ rawContent: Any?, path: String, issues: inout [ViewValidationIssue]) {
        guard let content = rawContent as? [Any], !content.isEmpty else {
            issues.append(.init(path: path, reason: "content must be a non-empty array"))
            return
        }

        for (index, node) in content.enumerated() {
            validateNode(node, path: "\(path)[\(index)]", issues: &issues)
        }
    }

    private static func validateView(_ rawView: Any, path: String, issues: inout [ViewValidationIssue]) {
        guard let view = rawView as? [String: Any] else {
            issues.append(.init(path: path, reason: "view must be an object"))
            return
        }

        guard view["id"] is String else {
            issues.append(.init(path: "\(path).id", reason: "id is required"))
            return
        }

        guard let type = view["type"] as? String else {
            issues.append(.init(path: "\(path).type", reason: "type is required"))
            return
        }

        guard supportedTypes.contains(type) else {
            issues.append(.init(path: "\(path).type", reason: "unsupported type '\(type)'"))
            return
        }

        guard let state = view["state"] as? String, supportedStates.contains(state) else {
            issues.append(.init(path: "\(path).state", reason: "state is required and must be supported"))
            return
        }

        guard let data = view["data"] as? [String: Any] else {
            issues.append(.init(path: "\(path).data", reason: "data is required and must be an object"))
            return
        }

        validateData(type: type, data: data, path: "\(path).data", issues: &issues)

        if let actions = view["actions"] {
            validateActions(actions, path: "\(path).actions", issues: &issues)
        }
    }

    private static func validateData(
        type: String,
        data: [String: Any],
        path: String,
        issues: inout [ViewValidationIssue]
    ) {
        switch type {
        case "map.snapshot":
            if data["center"] as? [String: Any] == nil {
                issues.append(.init(path: "\(path).center", reason: "center is required"))
            }
            if data["pins"] as? [Any] == nil && data["annotations"] as? [Any] == nil {
                issues.append(.init(path: path, reason: "pins or annotations is required"))
            }
        case "map.route":
            guard let pathItems = data["path"] as? [Any] ?? data["polyline"] as? [Any], pathItems.count >= 2 else {
                issues.append(.init(path: "\(path).path", reason: "path must contain at least two coordinates"))
                return
            }
        case "image.preview":
            if data["url"] as? String == nil && data["placeholder"] as? String == nil {
                issues.append(.init(path: path, reason: "url or placeholder is required"))
            }
        case "image.gallery":
            guard let images = data["images"] as? [Any], !images.isEmpty else {
                issues.append(.init(path: "\(path).images", reason: "images must be a non-empty array"))
                return
            }
        case "calendar.timeline":
            guard let events = data["events"] as? [Any] else {
                issues.append(.init(path: "\(path).events", reason: "events is required"))
                return
            }
            for (index, item) in events.enumerated() {
                guard let event = item as? [String: Any] else {
                    issues.append(.init(path: "\(path).events[\(index)]", reason: "event must be an object"))
                    continue
                }
                for key in ["title", "start", "end"] where event[key] as? String == nil {
                    issues.append(.init(path: "\(path).events[\(index)].\(key)", reason: "\(key) is required"))
                }
            }
        case "health.trend":
            guard let metrics = data["metrics"] as? [Any], !metrics.isEmpty else {
                issues.append(.init(path: "\(path).metrics", reason: "metrics must be a non-empty array"))
                return
            }
        case "places.list":
            guard let places = data["places"] as? [Any] else {
                issues.append(.init(path: "\(path).places", reason: "places is required"))
                return
            }
            for (index, item) in places.enumerated() {
                guard let place = item as? [String: Any] else {
                    issues.append(.init(path: "\(path).places[\(index)]", reason: "place must be an object"))
                    continue
                }
                for key in ["id", "name", "address"] where place[key] as? String == nil {
                    issues.append(.init(path: "\(path).places[\(index)].\(key)", reason: "\(key) is required"))
                }
            }
        case "system.loading":
            if data["message"] as? String == nil {
                issues.append(.init(path: "\(path).message", reason: "message is required"))
            }
        case "system.error":
            if data["reason"] as? String == nil {
                issues.append(.init(path: "\(path).reason", reason: "reason is required"))
            }
        default:
            return
        }
    }

    private static func validateActions(_ rawActions: Any, path: String, issues: inout [ViewValidationIssue]) {
        guard let actions = rawActions as? [Any] else {
            issues.append(.init(path: path, reason: "actions must be an array"))
            return
        }

        for (index, item) in actions.enumerated() {
            guard let action = item as? [String: Any] else {
                issues.append(.init(path: "\(path)[\(index)]", reason: "action must be an object"))
                continue
            }

            guard let type = action["type"] as? String, supportedActionTypes.contains(type) else {
                issues.append(.init(path: "\(path)[\(index)].type", reason: "type is required and must be supported"))
                continue
            }

            if action["label"] as? String == nil {
                issues.append(.init(path: "\(path)[\(index)].label", reason: "label is required"))
            }

            if type == "invoke", action["target"] as? [String: Any] == nil {
                issues.append(.init(path: "\(path)[\(index)].target", reason: "target is required for invoke"))
            }
        }
    }
}

private enum ViewDocumentError: Error {
    case invalidJSONObject(String)
}
