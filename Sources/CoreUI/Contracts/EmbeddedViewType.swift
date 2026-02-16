public enum EmbeddedViewType: String, CaseIterable, Sendable {
    case mapSnapshot = "map_snapshot"
    case imagePreview = "image_preview"
    case calendarTimeline = "calendar_timeline"
    case healthTrend = "health_trend"
    case schemaError = "schema_error_view"
    case loadingState = "loading_view"
}
