import SwiftUI

struct ContentView: View {
    @StateObject private var preferences = UserPreferencesManager.shared
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Ana Sayfa", systemImage: "house")
            }
            .tag(0)
            
            NavigationView {
                FavoritesView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Favoriler", systemImage: "heart")
            }
            .tag(1)
            
            NavigationView {
                SettingsView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Ayarlar", systemImage: "gear")
            }
            .tag(2)
        }
        .preferredColorScheme(preferences.preferences.colorScheme.uiColorScheme)
    }
}

#Preview {
    ContentView()
} 