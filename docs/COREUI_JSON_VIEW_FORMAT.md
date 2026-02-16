# CoreUI JSON View Format (Minimal Spec)

## 1. Scope

この仕様は、LLM が出力する CoreUI 表示 JSON の最小契約を定義する。

- テキストのみで十分な場合は `ui` を出力しない。
- View が必要な場合のみ `ui.views` を出力する。
- 1メッセージ内で複数 View を同時表示できる。

## 2. Top-Level Contract

```json
{
  "schemaVersion": "1.1",
  "message": "ユーザーに見せる本文",
  "ui": {
    "layout": "v",
    "views": []
  }
}
```

- `schemaVersion`: 必須。現在は `"1.1"`。
- `message`: 必須。常にチャット本文として表示。
- `ui`: 任意。未指定なら Text 表示のみ。

## 3. UI Contract

```json
{
  "layout": "v",
  "views": [
    {
      "kind": "map",
      "payload": {}
    }
  ]
}
```

- `layout`: 任意。
  - `"v"` = 縦積み
  - `"h"` = 横並び（狭い幅ではホストが自動で `"v"` へフォールバック）
- `views`: 必須（`ui` がある場合）。1件以上。

## 4. View Item Contract

```json
{
  "kind": "map",
  "payload": {},
  "actions": []
}
```

- `kind`: 必須。
  - `map`
  - `image`
  - `calendar`
  - `health`
  - `loading`
  - `schema_error`
- `payload`: 必須。`kind` ごとに厳格デコード。
- `actions`: 任意。必要時のみ付与。

## 5. Action Contract (Optional)

```json
{
  "label": "母に送る",
  "type": "tool",
  "name": "share_location",
  "input": { "to": "母" }
}
```

- 必須: `label`, `type`
- `type`:
  - `tool`
  - `fullscreen`
  - `dismiss`
- `tool` のときのみ:
  - `name`: ツール名
  - `input`: ツール入力

## 6. Payload Formats by View Kind

### 6.1 map

`kind: "map"` は `snapshot` と `route` の2形式をサポートする。

#### 6.1.1 map snapshot

```json
{
  "kind": "map",
  "payload": {
    "center": { "lat": 35.681236, "lng": 139.767125 },
    "pins": [
      {
        "id": "current",
        "title": "現在地",
        "coord": { "lat": 35.681236, "lng": 139.767125 }
      }
    ],
    "route": {
      "etaMin": 17,
      "distanceM": 5200
    },
    "summary": [
      "到着見込み 16:32"
    ]
  }
}
```

- 必須: `center`, `pins`
- 任意: `route`, `summary`

#### 6.1.2 map route

```json
{
  "kind": "map",
  "payload": {
    "path": [
      { "lat": 35.681236, "lng": 139.767125 },
      { "lat": 35.6889, "lng": 139.7512 }
    ],
    "origin": {
      "id": "origin",
      "title": "現在地",
      "coord": { "lat": 35.681236, "lng": 139.767125 }
    },
    "destination": {
      "id": "destination",
      "title": "赤坂クリニック",
      "coord": { "lat": 35.6889, "lng": 139.7512 }
    },
    "route": {
      "etaMin": 17,
      "distanceM": 5200
    },
    "steps": [
      { "stepID": "s1", "text": "外堀通りを南へ 600m 直進" }
    ],
    "transport": "walk",
    "summary": [
      "到着見込み 16:32"
    ]
  }
}
```

- 必須: `path`（2点以上）
- 任意: `origin`, `destination`, `waypoints`, `route`, `steps`, `transport`, `summary`

### 6.2 image

```json
{
  "kind": "image",
  "payload": {
    "url": "https://example.com/photo.jpg",
    "title": "共有前プレビュー",
    "subtitle": "位置情報付き",
    "meta": {
      "共有先": "母",
      "撮影日": "2026-02-17"
    }
  }
}
```

- 必須: `url` または `placeholder` のどちらか
- 任意: `title`, `subtitle`, `meta`

### 6.3 calendar

```json
{
  "kind": "calendar",
  "payload": {
    "timezone": "Asia/Tokyo",
    "events": [
      {
        "id": "e1",
        "title": "定期通院",
        "start": "2026-02-17T16:40:00+09:00",
        "end": "2026-02-17T17:10:00+09:00",
        "location": "赤坂クリニック",
        "travelMin": 17,
        "conflict": false
      }
    ]
  }
}
```

- 必須:
  - `events[].title`
  - `events[].start`
  - `events[].end`
- 任意:
  - `timezone`
  - `events[].location`
  - `events[].travelMin`
  - `events[].conflict`

### 6.4 health

```json
{
  "kind": "health",
  "payload": {
    "period": "過去7日",
    "metrics": [
      {
        "label": "歩数",
        "unit": "歩",
        "current": 8420,
        "prev": 7100,
        "series": [5600, 6100, 6800, 7200, 7000, 7900, 8420]
      }
    ],
    "alerts": ["睡眠時間が短い"]
  }
}
```

- 必須:
  - `metrics[].label`
  - `metrics[].unit`
  - `metrics[].current`
  - `metrics[].prev`
  - `metrics[].series`
- 任意:
  - `period`
  - `alerts`

### 6.5 loading

```json
{
  "kind": "loading",
  "payload": {
    "message": "地図を準備しています…"
  }
}
```

- 必須: `message`

### 6.6 schema_error

```json
{
  "kind": "schema_error",
  "payload": {
    "reason": "calendar.events が不正です"
  }
}
```

- 必須: `reason`

## 7. JSON Schema Constraints

- `calendar.events[].start` は `type: string, format: date-time`
- `calendar.events[].end` は `type: string, format: date-time`

キー名に `ISO8601` を含める必要はない。フォーマット制約は JSON Schema 側で定義する。

## 8. Rendering Rules

- すべての View は横幅を常に最大使用する。
- `layout: "h"` 指定時でも、狭い幅ではホストが `"v"` にフォールバックする。
- 複数 View の同時表示を許可する（例: `map` + `calendar`）。
- 部分的に decode に失敗しても、失敗した View のみ `schema_error` へフォールバックし、`message` は保持する。
