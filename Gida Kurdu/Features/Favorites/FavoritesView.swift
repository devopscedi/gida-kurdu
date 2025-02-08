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
                VStack(spacing: 16) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Favori Öğe Yok")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Favori öğeleriniz burada görünecek")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    NavigationView {
        FavoritesView()
    }
} 