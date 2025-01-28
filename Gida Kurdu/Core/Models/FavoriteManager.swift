import Foundation

final class FavoriteManager: ObservableObject {
    static let shared = FavoriteManager()
    private let defaults = UserDefaults.standard
    private let favoritesKey = "favoriteItems"
    
    @Published private(set) var favoriteItems: Set<String> = []
    
    private init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        if let data = defaults.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteItems = favorites
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteItems) {
            defaults.set(data, forKey: favoritesKey)
        }
    }
    
    func toggleFavorite(for itemId: String) {
        if favoriteItems.contains(itemId) {
            favoriteItems.remove(itemId)
        } else {
            favoriteItems.insert(itemId)
        }
        saveFavorites()
    }
    
    func isFavorite(_ itemId: String) -> Bool {
        favoriteItems.contains(itemId)
    }
} 