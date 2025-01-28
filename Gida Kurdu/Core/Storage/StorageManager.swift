import Foundation

enum StorageError: Error {
    case saveError
    case readError
    case deleteError
    case notFound
}

protocol StorageManagerProtocol {
    func save<T: Encodable>(_ item: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T
    func delete(forKey key: String) throws
    func exists(forKey key: String) -> Bool
}

final class StorageManager: StorageManagerProtocol {
    static let shared = StorageManager()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func save<T: Encodable>(_ item: T, forKey key: String) throws {
        do {
            let data = try JSONEncoder().encode(item)
            userDefaults.set(data, forKey: key)
        } catch {
            throw StorageError.saveError
        }
    }
    
    func load<T: Decodable>(forKey key: String) throws -> T {
        guard let data = userDefaults.data(forKey: key) else {
            throw StorageError.notFound
        }
        
        do {
            let item = try JSONDecoder().decode(T.self, from: data)
            return item
        } catch {
            throw StorageError.readError
        }
    }
    
    func delete(forKey key: String) throws {
        guard exists(forKey: key) else {
            throw StorageError.notFound
        }
        userDefaults.removeObject(forKey: key)
    }
    
    func exists(forKey key: String) -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
}

// MARK: - UserDefaults Extension for Type Safety
extension UserDefaults {
    enum Keys {
        static let userPreferences = "user_preferences"
        static let lastUpdateTime = "last_update_time"
        static let notificationSettings = "notification_settings"
    }
} 