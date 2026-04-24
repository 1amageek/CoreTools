# CoreUI Philosophy

CoreUI is a semantic presentation layer for agent-native applications.

It is not a JSON version of HTML, a canvas protocol, or a pixel-level layout language. CoreUI describes what should be presented to the user, why it matters, and what safe actions are available. The host application decides the exact SwiftUI rendering, platform adaptation, accessibility, and interaction details.

## Principles

### Semantics First

CoreUI documents must preserve meaning. A view should say `calendar.timeline`, `map.route`, or `places.list`, not encode an anonymous visual box that only happens to look like a calendar, map, or list.

Semantic names are not verbosity. They are the contract that makes documents understandable to humans, LLMs, logs, validators, skills, and remote agents.

### SwiftUI-Inspired, Not DOM-Inspired

CoreUI should feel closer to SwiftUI than to HTML.

The document tree should be composed from a small set of semantic nodes:

- `vstack`: vertical composition
- `hstack`: horizontal composition
- `section`: titled semantic grouping
- `view`: leaf renderer backed by typed data

Containers use `content`, not `children`. `content` better matches the idea that a node owns meaningful presentation content, rather than exposing a low-level tree structure.

### Bounded Composition

Nested structure is useful, but unbounded nesting is harmful. CoreUI should support enough composition to express common agent results, while staying easy to validate and reliable on constrained surfaces such as watchOS.

The format should prefer:

- Shallow trees over deeply nested layouts
- Semantic grouping over arbitrary containers
- Host-driven adaptation over model-controlled layout
- A small set of legal node shapes over open-ended JSON

### State Is Part Of UX

Empty, loading, permission, partial, and error states are not exceptional rendering failures. They are normal user experiences and must be represented explicitly.

Every leaf view should have a state:

- `content`
- `empty`
- `loading`
- `error`
- `permissionRequired`
- `partial`

A query returning zero results is a successful result with an `empty` state. It should not be rendered as broken UI.

### Data Over Drawing Instructions

CoreUI leaf views should carry typed data, not drawing instructions.

A map view should receive coordinates, route summaries, pins, and steps. It should not receive line colors, pixel offsets, or arbitrary drawing commands. A calendar view should receive events and timezone context. It should not receive a hand-authored layout.

This keeps documents compact, testable, accessible, and portable across Apple platforms.

### Host Authority

The host owns final rendering authority.

CoreUI documents may express semantic intent, layout direction, state, data, and actions. The host decides:

- Exact SwiftUI components
- Spacing and typography
- Platform-specific adaptation
- Accessibility behavior
- Fullscreen presentation
- Safety confirmation UI

This boundary keeps LLM output useful without allowing it to become an unsafe or fragile UI implementation language.

### Actions Are Capabilities

Actions should describe user-visible capabilities, not hidden side effects.

An action should include a label, target, input, and safety metadata. The target may later represent a local tool, skill, app intent, URL, or remote agent. Side-effecting actions must be confirmable by the host.

CoreUI should make the next useful step obvious to the user while preserving consent and control.

### Format Is A Contract, Not A Prompt Trick

CoreUI should be easy for an LLM to produce, but it must not depend on fragile prompt behavior.

The format needs strict validation, deterministic normalization, and safe fallback behavior. Invalid subtrees should degrade locally when possible. A broken view should not invalidate the entire document unless the document itself is unreadable.

## CoreUI V1 Shape

CoreUI v1 uses a SwiftUI-inspired semantic tree:

```json
{
  "schema": "coreui/1",
  "message": "今日の予定と移動です",
  "context": {
    "locale": "ja-JP",
    "timezone": "Asia/Tokyo"
  },
  "ui": {
    "body": {
      "vstack": {
        "spacing": "regular",
        "content": [
          {
            "section": {
              "title": "Today",
              "content": [
                {
                  "view": {
                    "id": "calendar",
                    "type": "calendar.timeline",
                    "state": "empty",
                    "data": {
                      "title": "No events",
                      "reason": "No calendar events were found for this range."
                    }
                  }
                },
                {
                  "view": {
                    "id": "route",
                    "type": "map.route",
                    "state": "content",
                    "data": {
                      "path": []
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
```

The core grammar is intentionally small:

```text
Document = schema + message + context? + ui?
UI = body
Node = vstack | hstack | section | view
Stack = spacing? + content
Section = title + subtitle? + content
View = id + type + state + data + actions?
```

Rules:

- A node must contain exactly one of `vstack`, `hstack`, `section`, or `view`.
- `content` is an array of nodes.
- `ui.body` is a single node.
- `view.id` is unique within the document.
- `view.type` uses `domain.variant`.
- `view.state` is required.
- `view.data` is required, even for empty or error states.
- Maximum supported depth should be bounded by the renderer.

## Compatibility

CoreUI is still early enough that the semantic tree is the v1 target. The implementation should not carry a compatibility layer for the previous experimental `schemaVersion/ui.views/kind/payload` shape.

The migration path should be direct:

1. Use `schema: "coreui/1"` for all new documents.
2. Use `ui.body` as the only UI root.
3. Use `content` for container contents.
4. Use `view.type`, `view.state`, and `view.data` for leaf renderers.
5. Keep the renderer surface intentionally small while preserving tree expressiveness for future expansion.

## Non-Goals

CoreUI should not become:

- A general HTML replacement
- A canvas drawing protocol
- A free-form component DSL
- A prompt-only convention without validation
- A way for LLMs to control unsafe side effects

The goal is not maximum visual freedom. The goal is trustworthy, semantic, adaptive presentation for agent workflows.
