# CoreUI JSON View Format

CoreUI is a semantic presentation format for agent-native UI.

It is intentionally SwiftUI-inspired. The format describes semantic structure and typed data, not pixel-level drawing instructions.

## 1. Document

```json
{
  "schema": "coreui/1",
  "message": "ユーザーに見せる本文",
  "context": {
    "locale": "ja-JP",
    "timezone": "Asia/Tokyo"
  },
  "ui": {
    "body": {
      "vstack": {
        "spacing": "regular",
        "content": []
      }
    }
  }
}
```

- `schema`: required. Current value is `"coreui/1"`.
- `message`: required. User-visible text.
- `context`: optional document-level defaults.
- `ui`: optional. Omit it when text is sufficient.
- `ui.body`: required when `ui` exists. It is a single node.

## 2. Node Grammar

Each node must contain exactly one of:

- `vstack`
- `hstack`
- `section`
- `view`

```text
Document = schema + message + context? + ui?
UI = body
Node = vstack | hstack | section | view
Stack = spacing? + content
Section = title + subtitle? + content
View = id + type + state + data + actions?
```

## 3. Containers

### 3.1 vstack

```json
{
  "vstack": {
    "spacing": "regular",
    "content": [
      { "view": { "...": "..." } }
    ]
  }
}
```

### 3.2 hstack

```json
{
  "hstack": {
    "spacing": "compact",
    "content": [
      { "view": { "...": "..." } }
    ]
  }
}
```

### 3.3 section

```json
{
  "section": {
    "title": "Today",
    "subtitle": "Schedule and route",
    "content": [
      { "view": { "...": "..." } }
    ]
  }
}
```

Container rules:

- `content` is a non-empty array of nodes.
- Supported spacing values: `tight`, `compact`, `regular`, `spacious`.
- The renderer may bound maximum supported depth.

## 4. Leaf View

```json
{
  "view": {
    "id": "calendar",
    "type": "calendar.timeline",
    "state": "content",
    "data": {},
    "actions": []
  }
}
```

- `id`: required and unique within the document.
- `type`: required semantic renderer type.
- `state`: required UX state.
- `data`: required typed data object.
- `actions`: optional user-visible capabilities.

Supported states:

- `content`
- `empty`
- `loading`
- `error`
- `permissionRequired`
- `partial`

## 5. Supported View Types

The initial implementation intentionally supports a limited renderer set:

- `map.snapshot`
- `map.route`
- `image.preview`
- `image.gallery`
- `calendar.timeline`
- `health.trend`
- `places.list`
- `system.loading`
- `system.error`

The tree structure is more expressive than the current renderer set by design. New renderers can be added without changing the container grammar.

## 6. Actions

```json
{
  "type": "invoke",
  "label": "詳しく見る",
  "target": {
    "kind": "tool",
    "name": "place_detail"
  },
  "input": {
    "placeID": "p1"
  },
  "safety": {
    "requiresConfirmation": false
  }
}
```

Supported action types:

- `invoke`
- `fullscreen`
- `dismiss`

`invoke` requires `target`. The host decides whether confirmation is required before side effects.

## 7. Example

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
                      "timezone": "Asia/Tokyo",
                      "events": []
                    }
                  }
                },
                {
                  "view": {
                    "id": "route",
                    "type": "map.route",
                    "state": "content",
                    "data": {
                      "path": [
                        { "lat": 35.681236, "lng": 139.767125 },
                        { "lat": 35.6889, "lng": 139.7512 }
                      ],
                      "route": {
                        "etaMin": 17,
                        "distanceM": 5200
                      }
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
