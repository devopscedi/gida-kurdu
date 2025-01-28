import SwiftUI

struct CitySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCities: Set<String>
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    
    var filteredCities: [String] {
        if searchText.isEmpty {
            return viewModel.availableCities.sorted()
        } else {
            return viewModel.availableCities
                .filter { $0.localizedCaseInsensitiveContains(searchText) }
                .sorted()
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredCities, id: \.self) { city in
                Button {
                    if selectedCities.contains(city) {
                        selectedCities.remove(city)
                    } else {
                        selectedCities.insert(city)
                    }
                } label: {
                    HStack {
                        Text(city)
                        Spacer()
                        if selectedCities.contains(city) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .searchable(text: $searchText, prompt: "Şehir Ara")
        .navigationTitle("Şehir Seçimi")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchItems()
        }
    }
} 