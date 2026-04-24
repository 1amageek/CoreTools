import MapKit
import SwiftUI

struct PlaceListView: View {
    let payload: PlaceListPayload

    @State private var selectedPlace: PlaceListItem?

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.compact) {
            WatchSectionTitle(text: "Places")
                .padding(.leading, LayoutTokens.regular)

            if payload.places.isEmpty {
                EmptyPlacesView()
                    .padding(.horizontal, LayoutTokens.regular)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: LayoutTokens.compact) {
                        ForEach(payload.places) { place in
                            PlaceCardView(place: place)
                                .onTapGesture { selectedPlace = place }
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.horizontal, LayoutTokens.regular, for: .scrollContent)
            }
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailSheet(place: place)
        }
    }
}

private struct EmptyPlacesView: View {
    var body: some View {
        HStack(alignment: .center, spacing: LayoutTokens.compact) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(WatchPalette.secondaryText)

            VStack(alignment: .leading, spacing: 2) {
                Text("No places found")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                Text("Try a broader query or a different area.")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(WatchPalette.secondaryText)
            }
        }
        .padding(LayoutTokens.compact)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: LayoutTokens.chipRadius)
                .fill(WatchPalette.elevated)
        )
    }
}

// MARK: - Card

private struct PlaceCardView: View {
    let place: PlaceListItem

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.tiny) {
            Image(systemName: categoryIcon(for: place.category))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WatchPalette.accent)

            Text(place.name)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .lineLimit(2)

            Text(place.address)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(WatchPalette.secondaryText)
                .lineLimit(2)
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .padding(LayoutTokens.compact)
        .frame(width: 150)
        .background(
            RoundedRectangle(cornerRadius: LayoutTokens.chipRadius)
                .fill(WatchPalette.elevated)
        )
    }
}

// MARK: - Detail Sheet

private struct PlaceDetailSheet: View {
    let place: PlaceListItem

    @Environment(\.dismiss) private var dismiss
    @State private var mapItem: MKMapItem?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    ContentUnavailableView(errorMessage, systemImage: "exclamationmark.triangle")
                } else {
                    detailContent
                }
            }
            .navigationTitle(place.name)
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .task { await fetchDetail() }
    }

    @ViewBuilder
    private var detailContent: some View {
        let item = mapItem
        let coordinate: CLLocationCoordinate2D? = item.map { resolveCoordinate(from: $0) }
            ?? place.coordinate.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }

        List {
            if let coordinate {
                Section {
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    ))) {
                        Marker(place.name, coordinate: coordinate)
                    }
                    .frame(height: 200)
                    .listRowInsets(EdgeInsets())
                }
            }

            Section {
                let address = item.flatMap { resolveAddress(from: $0) } ?? place.address
                Label(address, systemImage: "mappin")

                if let phone = item?.phoneNumber, !phone.isEmpty {
                    Link(destination: URL(string: "tel:\(phone)")!) {
                        Label(phone, systemImage: "phone")
                    }
                }

                if let url = item?.url {
                    Link(destination: url) {
                        Label(url.host ?? url.absoluteString, systemImage: "safari")
                    }
                }

                if let category = item?.pointOfInterestCategory {
                    Label(category.displayName, systemImage: categoryIcon(forPOI: category))
                } else if let category = place.category, !category.isEmpty {
                    Label(category, systemImage: categoryIcon(for: category))
                }
            }
        }
    }

    private func fetchDetail() async {
        defer { isLoading = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = place.name

        if let coordinate = place.coordinate {
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }

        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            mapItem = response.mapItems.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - MKMapItem Helpers

private func resolveCoordinate(from item: MKMapItem) -> CLLocationCoordinate2D {
    item.location.coordinate
}

private func resolveAddress(from item: MKMapItem) -> String? {
    if let address = item.address {
        return address.fullAddress
    }
    return nil
}

// MARK: - MKPointOfInterestCategory Extension

private extension MKPointOfInterestCategory {
    var displayName: String {
        switch self {
        case .restaurant: return "Restaurant"
        case .cafe: return "Cafe"
        case .hotel: return "Hotel"
        case .store: return "Store"
        case .park: return "Park"
        case .hospital: return "Hospital"
        case .school: return "School"
        case .gasStation: return "Gas Station"
        case .parking: return "Parking"
        case .publicTransport: return "Public Transport"
        case .museum: return "Museum"
        case .theater: return "Theater"
        case .nightlife: return "Nightlife"
        case .pharmacy: return "Pharmacy"
        case .bakery: return "Bakery"
        case .bank: return "Bank"
        case .postOffice: return "Post Office"
        default: return rawValue.replacingOccurrences(of: "MKPOICategory", with: "")
        }
    }
}

// MARK: - Category Icon

func categoryIcon(for category: String?) -> String {
    switch category?.lowercased() {
    case "restaurant", "food": return "fork.knife"
    case "cafe", "coffee": return "cup.and.saucer.fill"
    case "hotel", "lodging": return "bed.double.fill"
    case "store", "shopping": return "bag.fill"
    case "park": return "leaf.fill"
    case "hospital", "health": return "cross.case.fill"
    case "school", "education": return "graduationcap.fill"
    case "gas", "fuel": return "fuelpump.fill"
    case "parking": return "p.square.fill"
    case "transit", "station": return "tram.fill"
    default: return "mappin.circle.fill"
    }
}

private func categoryIcon(forPOI category: MKPointOfInterestCategory) -> String {
    switch category {
    case .restaurant: return "fork.knife"
    case .cafe: return "cup.and.saucer.fill"
    case .hotel: return "bed.double.fill"
    case .store: return "bag.fill"
    case .park: return "leaf.fill"
    case .hospital: return "cross.case.fill"
    case .school: return "graduationcap.fill"
    case .gasStation: return "fuelpump.fill"
    case .parking: return "p.square.fill"
    case .publicTransport: return "tram.fill"
    case .museum: return "building.columns.fill"
    case .theater: return "theatermasks.fill"
    case .pharmacy: return "cross.vial.fill"
    case .bakery: return "birthday.cake.fill"
    case .bank: return "banknote.fill"
    default: return "mappin.circle.fill"
    }
}

#Preview {
    PlaceListView(payload: PlaceListPayload(places: [
        PlaceListItem(id: "1", name: "Blue Bottle Coffee", address: "66 Mint St, San Francisco", category: "cafe", phone: "+1-510-653-3394"),
        PlaceListItem(id: "2", name: "Tartine Bakery", address: "600 Guerrero St, San Francisco", category: "food"),
        PlaceListItem(id: "3", name: "Golden Gate Park", address: "San Francisco, CA", category: "park",
                       coordinate: CoordinatePayload(latitude: 37.7694, longitude: -122.4862)),
    ]))
    .frame(width: 400)
}
