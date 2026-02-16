# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# ビルド
swift build

# テスト（タイムアウト推奨: 30秒）
swift test

# 特定テストスイートの実行
swift test --filter CoreToolsTests

# リリースビルド
swift build -c release
```

リンター・フォーマッターは未設定。

## Architecture

CoreTools は iOS/macOS の Apple コアテクノロジー（14種）を **OpenFoundationModels の Tool システム** に準拠してラップするライブラリ。Tool 実行と **Generable ベースの UI 提供**の両方を担う。

### Swift Package 構成

- Swift Tools Version: **6.2**
- プロダクト: `CoreTools`（ライブラリ）
- 外部依存: なし（Apple フレームワーク + OpenFoundationModels を使用予定）
- テスト: Swift Testing フレームワーク（`@Test`, `#expect`）

### Tool 設計パターン

各 Tool は OpenFoundationModels の `Tool` プロトコルに準拠する:
- Arguments: `@Generable` 構造体で型安全に定義
- Output: `PromptRepresentable` 準拠 + `@Generable`
- 実行: `call(arguments:) async throws -> Output`
- エラー: `throws` で返し、上位の `LanguageModelSession` で集約

### 共通データ契約

- **Arguments 共通項目**: `requestId: UUID`, `timestamp: Date`, `consent: Bool`（副作用操作で必須）, `locale: String`
- **Output 共通項目**: `status` (`success`/`failure`/`requires_ui_confirmation`), `message`, `nextAction?`, `payload: Generable`
- **エラー分類**: `permissionDenied`, `serviceUnavailable`, `invalidInput`, `timeout`, `notFound`, `operationFailed`

### Generable UI 必須条件

以下に該当する処理は Generable UI（確認画面）を必ず提供する:
- 地図上の確認が必要（位置共有、経路、ジオフェンス）
- 副作用が大きい（通知送信、家電操作、データ共有）
- 個人情報を扱う（健康、連絡先、写真）
- 相手・端末の選択が必要（共有先、近接端末、BLE デバイス）

### 対象テクノロジー（14種）と MVP 優先順位

1. CoreLocation + MapKit + Contacts + UserNotifications（位置共有導線）
2. EventKit + MapKit + UserNotifications（予定/出発導線）
3. CoreBluetooth + MultipeerConnectivity + NearbyInteraction（近接連携）
4. CoreSpotlight（横断検索）
5. HealthKit + CoreMotion + HomeKit + LocalAuthentication（高機能導線）

詳細仕様は `docs/CORETOOLS_REQUIREMENTS_SPEC.md` を参照。
