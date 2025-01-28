import SwiftUI

struct FavoritesView: View {
    @StateObject private var favoriteManager = FavoriteManager.shared
    @StateObject private var viewModel = HomeViewModel()
    
    var favoriteItems: [FoodItem] {
        viewModel.foodItems.filter { favoriteManager.isFavorite($0.id) }
    }
    
    var body: some View {
        Group {
            if favoriteItems.isEmpty {
                ContentUnavailableView(
                    "Favori Öğe Yok",
                    systemImage: "heart.slash",
                    description: Text("Favori öğeleriniz burada görünecek")
                )
            } else {
                ScrollView {
                    // Favori Sayısı
                    HStack {
                        Text("\(favoriteItems.count) favori öğe")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(favoriteItems) { item in
                            NavigationLink(destination: FoodItemDetailView(item: item)) {
                                FoodItemCard(item: item)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .navigationTitle("Favoriler")
        .onAppear {
            if viewModel.foodItems.isEmpty {
                viewModel.fetchItems()
            }
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
} 