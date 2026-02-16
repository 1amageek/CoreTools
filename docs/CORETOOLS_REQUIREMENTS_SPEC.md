# CoreTools 要件仕様（v0.1）

更新日: 2026-02-16

## 1. 目的

CoreTools は、iOS/macOS から Apple のコアテクノロジーへアクセスする生活者向け機能を、OpenFoundationModels の Tool システムに準拠して提供する。  
本仕様は、Tool 実行だけでなく Generable ベースの UI 提供を前提として定義する。

## 2. スコープ

対象技術は以下の 14 テクノロジーとする。

1. CoreLocation
2. MapKit
3. UserNotifications
4. EventKit
5. Contacts
6. PhotoKit
7. HealthKit
8. CoreMotion
9. HomeKit
10. LocalAuthentication
11. MultipeerConnectivity
12. NearbyInteraction
13. CoreSpotlight
14. CoreBluetooth

## 2.1 モジュール構成

UI は `CoreTools` から分離し、`CoreUI` モジュールで提供する。

- `CoreTools`:
  - OpenFoundationModels 準拠 Tool の実行
  - 各 Apple フレームワークへのアクセス
  - ドメインロジック、権限判定、エラー分類
- `CoreUI`:
  - Generable UI コンポーネント
  - 地図、確認ダイアログ、デバイス選択、検索結果表示
  - `CoreTools` の出力を表示・確認・再実行する UI 層

依存方向は `CoreUI -> CoreTools` とし、逆依存を禁止する。

## 2.2 CoreUI JSON 仕様

CoreUI の LLM 出力 JSON 最小契約は以下の別紙を正とする。

- `docs/COREUI_JSON_VIEW_FORMAT.md`

## 3. OpenFoundationModels 準拠の共通仕様

### 3.1 Tool 構造

各 Tool は OpenFoundationModels の `Tool` に準拠し、以下を満たす。

- `name: String`
- `description: String`
- `parameters: GenerationSchema`
- `includesSchemaInInstructions: Bool`（既定値 `true`）
- `call(arguments:) async throws -> Output`

### 3.2 Arguments / Output

- Arguments は `@Generable` を利用した構造体で定義する。
- Output は `PromptRepresentable` 準拠とし、構造化データは `@Generable` を利用する。
- すべての Tool は型安全な入出力を持ち、`GeneratedContent` との相互変換を可能にする。

### 3.3 実行とエラー

- Tool は `LanguageModelSession` の Tool 実行ループで順次実行される。
- エラーは `throws` で返し、上位で `GenerationError.toolExecutionFailed` 等へ集約される前提とする。
- 失敗時は UI 側で再試行・権限再確認・代替導線を提示する。

### 3.4 UI（Generable）連携の原則

以下に該当する処理は Generable UI を必須とする。

- 地図上の確認が必要（位置共有、経路、ジオフェンス）
- 副作用が大きい（通知送信、家電操作、データ共有）
- 個人情報を扱う（健康、連絡先、写真）
- 相手・端末の選択が必要（共有先、近接端末、BLE デバイス）

## 4. 複合ユースケース仕様（Tool + Generable）

### UC-01 現在地を母親に送る

- 組み合わせ: CoreLocation + Contacts + MapKit + UserNotifications / MultipeerConnectivity
- Tool 要件:
  - 現在地取得
  - 宛先連絡先解決
  - 共有チャネル選択
- Generable UI 要件:
  - 地図ピンと住所表示
  - 宛先確認
  - 送信内容最終確認

### UC-02 待ち合わせの ETA 付き位置共有

- 組み合わせ: CoreLocation + MapKit + Contacts
- Tool 要件:
  - 現在地取得
  - 経路探索と ETA 算出
  - 共有メッセージ生成
- Generable UI 要件:
  - ルート候補（徒歩/車）
  - ETA 比較
  - 送信確認

### UC-03 学校到着/出発の見守り通知

- 組み合わせ: CoreLocation + UserNotifications + Contacts
- Tool 要件:
  - ジオフェンス開始/停止
  - 入退域イベント通知
- Generable UI 要件:
  - ジオフェンス半径編集
  - 通知先選択

### UC-04 通院アシスト

- 組み合わせ: EventKit + MapKit + HealthKit + UserNotifications
- Tool 要件:
  - 当日予定抽出
  - 病院までの経路/出発時刻計算
  - 必要健康指標の要約
- Generable UI 要件:
  - 出発時刻カード
  - 経路表示
  - 診察向けサマリー表示

### UC-05 転倒疑い時の緊急連絡

- 組み合わせ: CoreMotion + CoreLocation + Contacts + UserNotifications
- Tool 要件:
  - 異常動作検知
  - 現在地取得
  - 緊急連絡先通知
- Generable UI 要件:
  - 誤検知キャンセル
  - 緊急送信確認
  - 地図表示

### UC-06 帰宅連動ホーム制御

- 組み合わせ: CoreLocation + HomeKit + UserNotifications
- Tool 要件:
  - 帰宅状態判定
  - シーン実行
  - 実行結果通知
- Generable UI 要件:
  - 実行対象アクセサリ選択
  - 実行確認

### UC-07 災害時オフライン連絡

- 組み合わせ: MultipeerConnectivity + CoreBluetooth + CoreLocation
- Tool 要件:
  - 近接端末探索
  - メッシュ送信
  - 位置添付
- Generable UI 要件:
  - 端末一覧
  - 送達状態
  - 優先度付きメッセージ編集

### UC-08 鍵/タグ探索

- 組み合わせ: CoreBluetooth + NearbyInteraction + CoreLocation
- Tool 要件:
  - BLE 検出
  - 方向/距離追跡
  - 最終既知位置記録
- Generable UI 要件:
  - レーダー表示
  - 距離インジケータ
  - 地図上の最終位置

### UC-09 写真付き位置共有

- 組み合わせ: PhotoKit + CoreLocation + Contacts + MapKit
- Tool 要件:
  - 写真選択
  - 位置情報付与/除去
  - 共有送信
- Generable UI 要件:
  - 写真プレビュー
  - 位置情報マスク切替
  - 共有確認

### UC-10 出発リマインド最適化

- 組み合わせ: EventKit + MapKit + UserNotifications + CoreLocation
- Tool 要件:
  - 次予定取得
  - 移動時間算出
  - 通知スケジュール
- Generable UI 要件:
  - 出発時刻スライダー
  - 交通手段切替

### UC-11 生活ログ横断検索

- 組み合わせ: CoreSpotlight + EventKit + PhotoKit + Contacts + MapKit
- Tool 要件:
  - 横断インデックス作成
  - 検索クエリ実行
  - 検索結果起点の再実行
- Generable UI 要件:
  - 結果タブ（予定/写真/連絡先/位置）
  - 再実行アクション

### UC-12 健康状態ベース行動提案

- 組み合わせ: HealthKit + CoreMotion + MapKit + UserNotifications
- Tool 要件:
  - 日次健康要約
  - 活動不足検知
  - 近場ルート提案
- Generable UI 要件:
  - 健康サマリーカード
  - 推奨ルート表示
  - 通知ON/OFF

## 5. 技術別仕様（必須 API / Tool / Generable UI）

### 5.1 CoreLocation

- 必須 API:
  - `CLLocationManager`
  - `requestWhenInUseAuthorization()`
  - `requestAlwaysAuthorization()`
  - `startUpdatingLocation()`
  - `startMonitoring(for:)` / `stopMonitoring(for:)`
  - `didEnterRegion` / `didExitRegion`
  - `CLGeocoder.geocodeAddressString(_:)`
  - `CLGeocoder.reverseGeocodeLocation(_:)`
- Tool:
  - `location_get_current`
  - `location_geocode`
  - `location_reverse_geocode`
  - `location_start_region_monitoring`
  - `location_stop_region_monitoring`
- Generable UI:
  - 位置共有確認地図
  - ジオフェンス編集（中心点/半径）
  - 権限状態と再許可導線

### 5.2 MapKit

- 必須 API:
  - `Map`（SwiftUI）/ `MKMapView`
  - `MKLocalSearch`
  - `MKDirections`
  - `MKRoute`
  - `MKMapItem`
  - `MKPointAnnotation`
  - `MKPolyline`
- Tool:
  - `map_search_places`
  - `map_calculate_route`
  - `map_estimate_eta`
  - `map_resolve_place_details`
- Generable UI:
  - 検索結果マップ
  - ルート候補比較（時間/距離）
  - ピン選択と確定 UI

### 5.3 UserNotifications

- 必須 API:
  - `UNUserNotificationCenter`
  - `requestAuthorization(options:)`
  - `UNNotificationRequest`
  - `UNTimeIntervalNotificationTrigger`
  - `UNCalendarNotificationTrigger`
  - `getPendingNotificationRequests()`
  - `removePendingNotificationRequests(withIdentifiers:)`
- Tool:
  - `notification_schedule_time`
  - `notification_schedule_calendar`
  - `notification_list_pending`
  - `notification_cancel`
- Generable UI:
  - 通知内容プレビュー
  - 通知時刻調整
  - 一覧管理画面

### 5.4 EventKit

- 必須 API:
  - `EKEventStore`
  - `requestFullAccessToEvents()`
  - `requestFullAccessToReminders()`
  - `events(matching:)`
  - `save(_:span:)` / `remove(_:span:)`
  - `fetchReminders(matching:)`
- Tool:
  - `calendar_list_events`
  - `calendar_create_event`
  - `calendar_update_event`
  - `calendar_delete_event`
  - `reminder_list`
  - `reminder_upsert`
- Generable UI:
  - 日/週予定ビュー
  - 予定作成フォーム
  - 予定確定前レビュー

### 5.5 Contacts

- 必須 API:
  - `CNContactStore`
  - `requestAccess(for: .contacts)`
  - `unifiedContacts(matching:keysToFetch:)`
  - `enumerateContacts(with:)`
  - `CNMutableContact`
  - `CNSaveRequest`
  - `CNContactFormatter`
- Tool:
  - `contacts_search`
  - `contacts_get_detail`
  - `contacts_create`
  - `contacts_update`
  - `contacts_resolve_relationship`
- Generable UI:
  - 候補連絡先選択
  - 重複連絡先マージ提案
  - 共有先最終確認

### 5.6 PhotoKit

- 必須 API:
  - `PHPhotoLibrary.requestAuthorization(for:)`
  - `PHAsset.fetchAssets(...)`
  - `PHAssetCollection.fetchAssetCollections(...)`
  - `PHImageManager.requestImage(...)`
  - `PHPhotoLibrary.performChanges(_:)`
  - `PHAssetChangeRequest`
  - `PHAssetCollectionChangeRequest`
  - `PHPickerViewController`
- Tool:
  - `photos_search_assets`
  - `photos_get_asset_metadata`
  - `photos_create_album`
  - `photos_add_to_album`
  - `photos_prepare_share_payload`
- Generable UI:
  - 写真ピッカー
  - メタデータ表示（撮影日時/位置）
  - 共有前マスク設定（位置情報）

### 5.7 HealthKit

- 必須 API:
  - `HKHealthStore`
  - `requestAuthorization(toShare:read:)`
  - `HKSampleQuery`
  - `HKStatisticsQuery`
  - `HKStatisticsCollectionQuery`
  - `HKAnchoredObjectQuery`
  - `enableBackgroundDelivery(...)`
- Tool:
  - `health_read_daily_summary`
  - `health_read_metric_range`
  - `health_detect_inactivity`
  - `health_generate_visit_summary`
- Generable UI:
  - 健康サマリーカード
  - 期間フィルタ
  - 共有項目の明示選択

### 5.8 CoreMotion

- 必須 API:
  - `CMMotionActivityManager.startActivityUpdates(to:withHandler:)`
  - `CMPedometer.queryPedometerData(from:to:withHandler:)`
  - `CMPedometer.startPedometerUpdates(from:withHandler:)`
  - `CMMotionManager.startDeviceMotionUpdates()`
  - `CMMotionManager.startAccelerometerUpdates()`
  - `stop...Updates` 系
- Tool:
  - `motion_read_activity_state`
  - `motion_read_step_count`
  - `motion_start_fall_watch`
  - `motion_stop_fall_watch`
- Generable UI:
  - 活動状態タイムライン
  - 異常検知時の確認ダイアログ
  - 日次活動サマリー

### 5.9 HomeKit

- 必須 API:
  - `HMHomeManager`
  - `HMHome`
  - `HMAccessory`
  - `HMCharacteristic.readValue(completionHandler:)`
  - `HMCharacteristic.writeValue(_:completionHandler:)`
  - `HMActionSet`
  - `HMEventTrigger`
- Tool:
  - `home_list_homes_and_accessories`
  - `home_read_characteristic`
  - `home_write_characteristic`
  - `home_run_action_set`
  - `home_toggle_scene_by_context`
- Generable UI:
  - ルーム/アクセサリ一覧
  - 実行前確認
  - 実行結果フィードバック

### 5.10 LocalAuthentication

- 必須 API:
  - `LAContext`
  - `canEvaluatePolicy(_:error:)`
  - `evaluatePolicy(_:localizedReason:reply:)`
  - `biometryType`
  - `invalidate()`
- Tool:
  - `auth_check_capability`
  - `auth_require_user_presence`
  - `auth_require_biometric`
- Generable UI:
  - 認証必要理由の明示
  - 失敗時の再試行導線
  - 生体不可時の代替導線

### 5.11 MultipeerConnectivity

- 必須 API:
  - `MCPeerID`
  - `MCSession`
  - `MCNearbyServiceAdvertiser`
  - `MCNearbyServiceBrowser`
  - `invitePeer(_:to:withContext:timeout:)`
  - `send(_:toPeers:with:)`
  - `startStream(withName:toPeer:)`
- Tool:
  - `peer_start_advertising`
  - `peer_start_browsing`
  - `peer_invite`
  - `peer_send_message`
  - `peer_transfer_blob`
- Generable UI:
  - 近接端末一覧
  - 接続承認 UI
  - 送達状態表示

#### 5.11.1 セッション開始ポリシー（必須）

- Agent セッション開始時に `advertise` と `browse` を同時開始する。
- 同時開始はブートストラップ時間（既定 `10〜20秒`）で運用し、接続成立後は片側を弱化または停止して電力消費を抑える。
- 双方同時検出時の二重招待を防ぐため、`peerID` の辞書順など deterministic ルールで invite 側を一意決定する。
- 未接続が継続する場合は scan 間隔を段階的に拡大する（バックオフ）。
- セッション終了時は `advertise` / `browse` / 関連セッションを必ず停止する。

### 5.12 NearbyInteraction

- 必須 API:
  - `NISession`
  - `NINearbyPeerConfiguration`
  - `run(_:)`
  - `invalidate()`
  - `NISessionDelegate.session(_:didUpdate:)`
  - `NINearbyObject.distance`
  - `NINearbyObject.direction`
  - `NIDiscoveryToken`
- 提供形態:
  - `NearbyInteraction` は原則 Tool ではなく `NearbyHarness` として提供する。
  - Harness は近接セッション管理と距離/方向の継続観測を担当し、Agent 実行コンテキストへ状態を供給する。
  - `NIDiscoveryToken` 交換は `MultipeerConnectivity` 経由で行う。
  - 任意で公開する Tool は `nearby_enable` / `nearby_disable` に限定する。
- Generable UI:
  - レーダー表示
  - 距離/方角インジケータ
  - セッション状態表示

#### 5.12.1 NearbyAdvisor（推奨）

- `NearbyHarness` とは別に `NearbyAdvisor` を設け、観測結果から行動提案を生成する。
- 主な提案:
  - 送信対象候補の絞り込み（誤送信リスク低減）
  - 最寄り中継端末の提案（メッシュ送達率向上）
  - 近接成立条件の確認提案（対面共有の安全性向上）
- Advisor は提案のみを行い、送信確定は必ず UI 確認を経る。

### 5.13 CoreSpotlight

- 必須 API:
  - `CSSearchableIndex`
  - `CSSearchableItem`
  - `CSSearchableItemAttributeSet`
  - `indexSearchableItems(_:)`
  - `deleteSearchableItems(withIdentifiers:)`
  - `deleteAllSearchableItems()`
  - `CSSearchQuery`
  - `NSUserActivity.isEligibleForSearch`
- Tool:
  - `spotlight_index_item`
  - `spotlight_index_bulk`
  - `spotlight_search`
  - `spotlight_delete_item`
  - `spotlight_clear_index`
- Generable UI:
  - 横断検索結果ビュー
  - コンテンツ種別フィルタ
  - 検索結果から再実行導線

### 5.14 CoreBluetooth

- 必須 API:
  - `CBCentralManager`
  - `scanForPeripherals(withServices:options:)`
  - `connect(_:options:)`
  - `cancelPeripheralConnection(_:)`
  - `CBPeripheral.discoverServices(_:)`
  - `CBPeripheral.discoverCharacteristics(_:for:)`
  - `CBPeripheral.readValue(for:)`
  - `CBPeripheral.writeValue(_:for:type:)`
  - `CBPeripheral.setNotifyValue(_:for:)`
- Tool:
  - `ble_start_scan`
  - `ble_stop_scan`
  - `ble_connect`
  - `ble_discover_services`
  - `ble_read_characteristic`
  - `ble_write_characteristic`
  - `ble_subscribe_characteristic`
- Generable UI:
  - デバイス一覧と信号強度
  - サービス/特性ブラウザ
  - ペアリング/接続状態 UI

## 6. 共通データ契約（最小）

### 6.1 共通 Arguments 項目

- `requestId: UUID`
- `timestamp: Date`
- `consent: Bool`（副作用操作では必須）
- `locale: String`

### 6.2 共通 Output 項目

- `status: "success" | "failure" | "requires_ui_confirmation"`
- `message: String`
- `nextAction: String?`
- `payload: Generable`（技術別）

### 6.3 共通エラー分類

- `permissionDenied`
- `serviceUnavailable`
- `invalidInput`
- `timeout`
- `notFound`
- `operationFailed`

## 7. セキュリティ・プライバシー要件

- 位置、健康、連絡先、写真、家電制御は明示同意を必須にする。
- 高リスク操作前に `LocalAuthentication` を要求できる設計にする。
- CoreSpotlight のインデックス対象は最小限に限定し、機微データは要マスキング。
- 共有系 Tool は「宛先」「内容」「送信手段」を UI で確認後に確定する。

## 8. 実装優先順位（MVP）

1. CoreLocation + MapKit + Contacts + UserNotifications（位置共有導線）
2. EventKit + MapKit + UserNotifications（予定/出発導線）
3. CoreBluetooth + MultipeerConnectivity + NearbyInteraction（近接連携導線）
4. CoreSpotlight（横断検索導線）
5. HealthKit + CoreMotion + HomeKit + LocalAuthentication（高機能導線）
