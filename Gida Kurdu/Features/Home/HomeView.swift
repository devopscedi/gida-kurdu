import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingFilters = false
    @State private var showingCityPicker = false
    @State private var showingDatePicker = false
    @State private var showingCategoryPicker = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Filtre seçenekleri
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        // İl seçimi
                        Button {
                            showingCityPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.circle")
                                Text(viewModel.selectedCity ?? "İl")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Tarih seçimi
                        Button {
                            showingDatePicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                Text(viewModel.selectedDate?.formatted(date: .abbreviated, time: .omitted) ?? "Tarih")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Ürün grubu seçimi
                        Button {
                            showingCategoryPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "tag")
                                Text(viewModel.selectedCategory ?? "Ürün Grubu")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Temizle butonu
                        Button {
                            viewModel.clearFilters()
                        } label: {
                            HStack {
                                Spacer(minLength: 0)
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(viewModel.hasActiveFilters ? .primary : .secondary)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
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
                            ForEach(viewModel.foodItems) { item in
                                NavigationLink(destination: FoodItemDetailView(item: item)) {
                                    FoodItemCard(item: item)
                                }
                                .buttonStyle(.plain)
                            }
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
        .navigationTitle("Gıda Kurdu")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.fetchItems()
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
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Veri Bulunamadı")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Aradığınız kriterlere uygun veri bulunamadı.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var cityPickerView: some View {
        NavigationView {
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
        NavigationView {
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
    }
    
    private var categoryPicker: some View {
        NavigationView {
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
        }
    }
}

#Preview {
    NavigationView {
        HomeView()
    }
} 
