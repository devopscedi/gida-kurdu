import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingFilters = false
    @State private var showingCityPicker = false
    @State private var showingDatePicker = false
    @State private var showingCategoryPicker = false
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationDestination(for: FoodItem.self) { item in
                    FoodItemDetailView(item: item)
                }
        }
        .onAppear {
            viewModel.fetchItems()
        }
    }
    
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Filtre seçenekleri
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        // İl seçimi
                        Button {
                            showingCityPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "mappin.circle")
                                Text(viewModel.selectedCity ?? "İl")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Tarih seçimi
                        Button {
                            showingDatePicker = true
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(viewModel.selectedDate?.formatted(date: .abbreviated, time: .omitted) ?? "Tarih")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Ürün grubu seçimi
                        Button {
                            showingCategoryPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "tag")
                                Text(viewModel.selectedCategory ?? "Ürün Grubu")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Temizle butonu
                        Button {
                            viewModel.clearFilters()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(viewModel.hasActiveFilters ? .primary : .secondary)
                        }
                        .disabled(!viewModel.hasActiveFilters)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else if viewModel.foodItems.isEmpty {
                    emptyView
                } else {
                    VStack(spacing: 8) {
                        // Kayıt Sayısı
                        HStack {
                            Text("\(viewModel.foodItems.count) kayıt")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Liste
                        LazyVStack(spacing: 0) {
                            foodItemsList
                        }
                    }
                }
            }
            .refreshable {
                await withCheckedContinuation { continuation in
                    viewModel.clearFilters()
                    viewModel.fetchItems()
                    continuation.resume()
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("Gıda Kurdu")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: viewModel.foodItems) { _ in
            print("Liste güncellendi: \(viewModel.foodItems.count) ürün var")
        }
        .sheet(isPresented: $showingCityPicker) {
            cityPickerView
        }
        .sheet(isPresented: $showingDatePicker) {
            datePicker
        }
        .sheet(isPresented: $showingCategoryPicker) {
            categoryPicker
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .padding()
    }
    
    private func errorView(_ error: String) -> some View {
        Text(error)
            .foregroundColor(.red)
            .padding()
    }
    
    private var emptyView: some View {
        ContentUnavailableView(
            "Veri Bulunamadı",
            systemImage: "magnifyingglass",
            description: Text("Aradığınız kriterlere uygun veri bulunamadı.")
        )
    }
    
    private var foodItemsList: some View {
        ForEach(viewModel.foodItems) { item in
            NavigationLink(value: item) {
                FoodItemCard(item: item)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var cityPickerView: some View {
        NavigationStack {
            List(viewModel.availableCities, id: \.self) { city in
                Button {
                    viewModel.selectedCity = city
                    showingCityPicker = false
                } label: {
                    HStack {
                        Text(city)
                        Spacer()
                        if viewModel.selectedCity == city {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("İl Seçin")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var datePicker: some View {
        NavigationStack {
            DatePicker(
                "Tarih Seçin",
                selection: Binding(
                    get: { viewModel.selectedDate ?? Date() },
                    set: { viewModel.selectedDate = $0 }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .navigationTitle("Tarih Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        showingDatePicker = false
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        viewModel.selectedDate = nil
                        showingDatePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var categoryPicker: some View {
        NavigationStack {
            List(viewModel.availableCategories, id: \.self) { category in
                Button {
                    viewModel.selectedCategory = category
                    showingCategoryPicker = false
                } label: {
                    HStack {
                        Text(category)
                        Spacer()
                        if viewModel.selectedCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Kategori Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        showingCategoryPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
} 
