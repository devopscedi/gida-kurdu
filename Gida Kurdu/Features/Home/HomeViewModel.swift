import Foundation
import Combine
import UIKit

final class HomeViewModel: ObservableObject {
    @Published private(set) var foodItems: [FoodItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    
    // Filtreler
    @Published var selectedCity: String? {
        didSet { applyFilters() }
    }
    @Published var selectedDate: Date? {
        didSet { applyFilters() }
    }
    @Published var selectedCategory: String? {
        didSet { applyFilters() }
    }
    
    // Filtreleme seçenekleri
    private var allItems: [FoodItem] = []
    var availableCities: [String] {
        Array(Set(allItems.compactMap { city in
            let cityName = city.location.city.removingHTMLTags
            return cityName.isEmpty || cityName == "-" ? nil : cityName
        })).sorted()
    }
    var availableCategories: [String] {
        Array(Set(allItems.map { $0.productGroup })).sorted()
    }
    
    var hasActiveFilters: Bool {
        selectedCity != nil || selectedDate != nil || selectedCategory != nil
    }
    
    private let api: FoodSafetyAPIProtocol
    private let userPreferences: UserPreferencesManager
    private let notificationManager: NotificationManager
    private var cancellables = Set<AnyCancellable>()
    private var lastFetchDate: Date?
    
    init(api: FoodSafetyAPIProtocol = FoodSafetyAPI(),
         userPreferences: UserPreferencesManager = .shared,
         notificationManager: NotificationManager = .shared) {
        self.api = api
        self.userPreferences = userPreferences
        self.notificationManager = notificationManager
        setupBackgroundFetch()
    }
    
    // Test ürünü oluştur ve işle
    func createTestItem() {
        // Test ürünü oluştur
        let testItem = FoodItem(
            id: UUID().uuidString,
            firmName: "Test Firma",
            productName: "Test Ürün - Güvenli Olmayan Gıda",
            productDescription: "Bu bir test ürünüdür. Sağlığa zararlı maddeler tespit edilmiştir.",
            partyNumber: "TEST-123",
            detectionDate: Date(),
            location: Location(
                city: "İstanbul",
                district: "Kadıköy",
                latitude: nil,
                longitude: nil
            ),
            riskLevel: .high,
            status: .active,
            brand: "Test Markası",
            productGroup: "Test Grubu"
        )
        
        // Test ürününü listeye ekle ve bildirim gönder
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Önce mevcut ürünleri kontrol et
            print("Mevcut ürün sayısı: \(self.allItems.count)")
            
            // Yeni ürünü ekle
            var updatedItems = self.allItems
            updatedItems.insert(testItem, at: 0)
            self.allItems = updatedItems
            
            print("Yeni ürün eklendi. Güncel ürün sayısı: \(self.allItems.count)")
            
            // Filtreleri uygula
            self.applyFilters()
            print("Filtreler uygulandı. Görünen ürün sayısı: \(self.foodItems.count)")
            
            // Bildirimi gönder
            self.notificationManager.scheduleNotification(for: testItem)
        }
    }
    
    func fetchItems() {
        isLoading = true
        error = nil
        fetchAllItems()
    }
    
    private func fetchAllItems() {
        api.fetchFoodItems(page: 0, pageSize: 1000)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] items in
                self?.processItems(items)
            }
            .store(in: &cancellables)
    }
    
    private func processItems(_ newItems: [FoodItem]) {
        let preferences = userPreferences.preferences
        let lastFetch = lastFetchDate ?? Date.distantPast
        
        let filteredItems = newItems
            .filter { $0.riskLevel.rawValue >= preferences.minimumRiskLevel.rawValue }
            .filter {
                preferences.selectedCities.isEmpty ||
                preferences.selectedCities.contains($0.location.city)
            }
            .sorted { $0.detectionDate > $1.detectionDate }
        
        // Yeni eklenen öğeler için bildirim gönder
        let newAddedItems = filteredItems.filter { $0.detectionDate > lastFetch }
        newAddedItems.forEach { item in
            notificationManager.scheduleNotification(for: item)
        }
        
        allItems = filteredItems
        lastFetchDate = Date()
        
        applyFilters()
    }
    
    private func applyFilters() {
        // Başlangıçta tüm öğeleri al
        var filteredItems = allItems
        
        // Şehir filtresini uygula
        if let city = selectedCity {
            filteredItems = filteredItems.filter { $0.location.city == city }
        }
        
        // Tarih filtresini uygula
        if let date = selectedDate {
            let calendar = Calendar.current
            filteredItems = filteredItems.filter {
                calendar.isDate($0.detectionDate, inSameDayAs: date)
            }
        }
        
        // Kategori filtresini uygula
        if let category = selectedCategory {
            filteredItems = filteredItems.filter { $0.productGroup == category }
        }
        
        // Sonuçları güncelle
        foodItems = filteredItems
    }
    
    func clearFilters() {
        selectedCity = nil
        selectedDate = nil
        selectedCategory = nil
    }
    
    private func setupBackgroundFetch() {
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.fetchItems()
            }
            .store(in: &cancellables)
    }
} 