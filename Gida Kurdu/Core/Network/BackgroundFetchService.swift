import Foundation
import BackgroundTasks
import Combine

final class BackgroundFetchService {
    static let shared = BackgroundFetchService()
    
    private let api: FoodSafetyAPIProtocol
    private let userPreferences: UserPreferencesManager
    private let notificationManager: NotificationManager
    private var cancellables = Set<AnyCancellable>()
    
    private init(api: FoodSafetyAPIProtocol = FoodSafetyAPI(),
                userPreferences: UserPreferencesManager = .shared,
                notificationManager: NotificationManager = .shared) {
        self.api = api
        self.userPreferences = userPreferences
        self.notificationManager = notificationManager
    }
    
    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.gidakurdu.fetch", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.gidakurdu.fetch")
        request.earliestBeginDate = Date(timeIntervalSinceNow: userPreferences.preferences.updateFrequency.interval)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        api.fetchFoodItems(page: 0, pageSize: 1000)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    task.setTaskCompleted(success: true)
                case .failure(let error):
                    print("Background fetch failed: \(error)")
                    task.setTaskCompleted(success: false)
                }
            } receiveValue: { [weak self] items in
                self?.processItems(items)
            }
            .store(in: &cancellables)
    }
    
    private func processItems(_ items: [FoodItem]) {
        let lastFetch = UserDefaults.standard.object(forKey: "lastBackgroundFetch") as? Date ?? Date.distantPast
        let newItems = items.filter { $0.detectionDate > lastFetch }
        
        newItems.forEach { item in
            notificationManager.scheduleNotification(for: item)
        }
        
        UserDefaults.standard.set(Date(), forKey: "lastBackgroundFetch")
    }
} 