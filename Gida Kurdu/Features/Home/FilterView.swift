import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var preferencesManager = UserPreferencesManager.shared
    @State private var preferences: UserPreferences
    @State private var showingCitySelection = false
    
    init() {
        _preferences = State(initialValue: UserPreferencesManager.shared.preferences)
    }
    
    func resetFilters() {
        let currentColorScheme = preferences.colorScheme
        preferences = .default
        preferences.colorScheme = currentColorScheme
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Risk Seviyesi") {
                    Picker("Minimum Risk Seviyesi", selection: $preferences.minimumRiskLevel) {
                        Text("Düşük").tag(FoodItem.RiskLevel.low)
                        Text("Orta").tag(FoodItem.RiskLevel.medium)
                        Text("Yüksek").tag(FoodItem.RiskLevel.high)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Konum") {
                    NavigationLink {
                        CitySelectionView(selectedCities: $preferences.selectedCities)
                    } label: {
                        HStack {
                            Text("Şehir Seçimi")
                            Spacer()
                            Text("\(preferences.selectedCities.count) şehir")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button("Filtreleri Sıfırla") {
                        resetFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filtreler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uygula") {
                        preferencesManager.preferences = preferences
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FilterView()
} 