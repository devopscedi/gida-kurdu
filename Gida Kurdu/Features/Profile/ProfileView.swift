import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var name: String {
        didSet {
            UserDefaults.standard.set(name, forKey: "user_name")
        }
    }
    @Published var email: String {
        didSet {
            UserDefaults.standard.set(email, forKey: "user_email")
        }
    }
    @Published var location: String {
        didSet {
            UserDefaults.standard.set(location, forKey: "user_location")
        }
    }
    @Published var notificationRadius: Double {
        didSet {
            UserDefaults.standard.set(notificationRadius, forKey: "notification_radius")
        }
    }
    
    init() {
        self.name = UserDefaults.standard.string(forKey: "user_name") ?? ""
        self.email = UserDefaults.standard.string(forKey: "user_email") ?? ""
        self.location = UserDefaults.standard.string(forKey: "user_location") ?? ""
        self.notificationRadius = UserDefaults.standard.double(forKey: "notification_radius")
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isEditing = false
    @State private var showingEditSheet = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.vertical)
                
                if viewModel.name.isEmpty && viewModel.email.isEmpty && !isEditing {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Text("Profili Düzenle")
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    if isEditing {
                        TextField("İsim", text: $viewModel.name)
                        TextField("E-posta", text: $viewModel.email)
                        TextField("Konum", text: $viewModel.location)
                    } else {
                        HStack {
                            Text("İsim")
                            Spacer()
                            Text(viewModel.name.isEmpty ? "Belirtilmemiş" : viewModel.name)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("E-posta")
                            Spacer()
                            Text(viewModel.email.isEmpty ? "Belirtilmemiş" : viewModel.email)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Konum")
                            Spacer()
                            Text(viewModel.location.isEmpty ? "Belirtilmemiş" : viewModel.location)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section("Bildirim Tercihleri") {
                VStack(alignment: .leading) {
                    Text("Bildirim Yarıçapı: \(Int(viewModel.notificationRadius)) km")
                    Slider(value: $viewModel.notificationRadius, in: 1...1000, step: 1)
                }
                
                NavigationLink("Bildirim Geçmişi") {
                    NotificationHistoryView()
                }
            }
            
            Section("Hesap") {
                Button(role: .destructive) {
                    // Profil bilgilerini sıfırla
                    viewModel.name = ""
                    viewModel.email = ""
                    viewModel.location = ""
                    viewModel.notificationRadius = 10.0
                } label: {
                    Label("Profili Sıfırla", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Profil")
        .navigationBarItems(trailing: Group {
            if !viewModel.name.isEmpty || !viewModel.email.isEmpty {
                Button(isEditing ? "Kaydet" : "Düzenle") {
                    isEditing.toggle()
                }
            }
        })
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                Form {
                    Section("Profil Bilgileri") {
                        TextField("İsim", text: $viewModel.name)
                        TextField("E-posta", text: $viewModel.email)
                        TextField("Konum", text: $viewModel.location)
                    }
                }
                .navigationTitle("Profili Düzenle")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("İptal") {
                        showingEditSheet = false
                    },
                    trailing: Button("Kaydet") {
                        showingEditSheet = false
                    }
                )
            }
        }
    }
}

class NotificationHistoryViewModel: ObservableObject {
    @Published private(set) var notifications: [FoodNotification] = []
    private let notificationManager = NotificationManager.shared
    
    init() {
        // Initial notifications
        notifications = notificationManager.notifications
        
        // Observe notifications changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationsDidChange),
            name: NSNotification.Name("NotificationsDidChange"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func notificationsDidChange() {
        notifications = notificationManager.notifications
    }
    
    func formatLocation(_ city: String) -> String {
        if city.isEmpty || city == "-" {
            return "Belirtilmemiş"
        }
        return city.removingHTMLTags
    }
}

struct NotificationHistoryView: View {
    @StateObject private var viewModel = NotificationHistoryViewModel()
    
    var body: some View {
        Group {
            if viewModel.notifications.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Bildirim Yok")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Henüz hiç bildirim almadınız")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.notifications) { notification in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(notification.foodItem.productName.removingHTMLTags)
                                    .font(.headline)
                                
                                Spacer()
                                
                                if !notification.isRead {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            
                            Text(viewModel.formatLocation(notification.foodItem.location.city))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(notification.date.formatted(.relative(presentation: .named)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Bildirim Geçmişi")
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
} 
