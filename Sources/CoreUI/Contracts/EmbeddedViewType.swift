public enum EmbeddedViewType: String, CaseIterable, Sendable {
    case mapSnapshot = "map_snapshot"
    case mapRoute = "map_route"
    case imagePreview = "image_preview"
    case imageGallery = "image_gallery"
    case calendarTimeline = "calendar_timeline"
    case healthTrend = "health_trend"
    case placeList = "place_list"
    case schemaError = "schema_error_view"
    case loadingState = "loading_view"
}
