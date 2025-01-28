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
                        LabeledContent("İsim", value: viewModel.name.isEmpty ? "Belirtilmemiş" : viewModel.name)
                        LabeledContent("E-posta", value: viewModel.email.isEmpty ? "Belirtilmemiş" : viewModel.email)
                        LabeledContent("Konum", value: viewModel.location.isEmpty ? "Belirtilmemiş" : viewModel.location)
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
        .toolbar {
            if !viewModel.name.isEmpty || !viewModel.email.isEmpty {
                Button(isEditing ? "Kaydet" : "Düzenle") {
                    isEditing.toggle()
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                Form {
                    Section("Profil Bilgileri") {
                        TextField("İsim", text: $viewModel.name)
                        TextField("E-posta", text: $viewModel.email)
                        TextField("Konum", text: $viewModel.location)
                    }
                }
                .navigationTitle("Profili Düzenle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("İptal") {
                            showingEditSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Kaydet") {
                            showingEditSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
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
                ContentUnavailableView(
                    "Bildirim Yok",
                    systemImage: "bell.slash",
                    description: Text("Henüz hiç bildirim almadınız")
                )
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
    NavigationStack {
        ProfileView()
    }
} 
