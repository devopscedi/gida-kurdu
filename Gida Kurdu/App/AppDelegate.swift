import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Arka plan görevlerini kaydet
        BackgroundFetchService.shared.register()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Arka plan güncellemesini başlat
        BackgroundFetchService.shared.scheduleAppRefresh()
        completionHandler(.newData)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Arka plan güncellemesini planla
        BackgroundFetchService.shared.scheduleAppRefresh()
    }
}

// MARK: - Scene Phase
extension AppDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
} 