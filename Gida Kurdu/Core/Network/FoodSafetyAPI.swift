import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError
    case invalidResponse
    case serverError(String)
}

protocol FoodSafetyAPIProtocol {
    func fetchFoodItems(page: Int, pageSize: Int) -> AnyPublisher<[FoodItem], APIError>
    func fetchFoodItemsByLocation(latitude: Double, longitude: Double, radius: Double) -> AnyPublisher<[FoodItem], APIError>
}

final class FoodSafetyAPI: FoodSafetyAPIProtocol {
    private let baseURL = "https://guvenilirgida.tarimorman.gov.tr/GuvenilirGida/GKD/DataTablesList"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    func fetchFoodItems(page: Int, pageSize: Int) -> AnyPublisher<[FoodItem], APIError> {
        var request = createBaseRequest()
        request.httpBody = createRequestBody(page: page, pageSize: pageSize)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.serverError("Status code: \(httpResponse.statusCode)")
                }
                
                return data
            }
            .decode(type: DataTablesResponse.self, decoder: JSONDecoder())
            .map { response in
                response.data.map { FoodItem(from: $0) }
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                if error is DecodingError {
                    return .decodingError
                }
                return .networkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchFoodItemsByLocation(latitude: Double, longitude: Double, radius: Double) -> AnyPublisher<[FoodItem], APIError> {
        // API konum bazlı filtreleme desteklemediği için tüm verileri çekip client-side filtreleme yapıyoruz
        return fetchFoodItems(page: 0, pageSize: 1000)
            .map { items in
                items.filter { item in
                    // Eğer item'ın koordinatları varsa mesafe kontrolü yap
                    if let itemLat = item.location.latitude,
                       let itemLon = item.location.longitude {
                        let distance = self.calculateDistance(
                            lat1: latitude,
                            lon1: longitude,
                            lat2: itemLat,
                            lon2: itemLon
                        )
                        return distance <= radius * 1000 // km to meters
                    }
                    return false
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func createBaseRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL)!)
        
        // Required headers
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("https://guvenilirgida.tarimorman.gov.tr", forHTTPHeaderField: "Origin")
        request.setValue("https://guvenilirgida.tarimorman.gov.tr/GuvenilirGida/GKD/Index", forHTTPHeaderField: "Referer")
        
        return request
    }
    
    private func createRequestBody(page: Int, pageSize: Int) -> Data {
        var params: [String: String] = [:]
        
        // Required parameters
        params["draw"] = "\(page + 1)"
        params["start"] = "\(page * pageSize)"
        params["length"] = "\(pageSize)"
        params["search[value]"] = ""
        params["search[regex]"] = "false"
        params["order[0][column]"] = "0"
        params["order[0][dir]"] = "desc"
        params["Order[0][column]"] = "DuyuruTarihi"
        params["Order[0][dir]"] = "desc"
        
        // Fixed parameters
        params["KamuoyuDuyuruAra.IdariYaptirimYasalDayanakIdler"] = "2,20"
        params["KamuoyuDuyuruAra.IdariYaptirimYasalDayanakId"] = ""
        params["SiteYayinDurumu"] = "True"
        params["_KamuoyuDuyuruAra_UrunGrupId"] = ""
        params["KamuoyuDuyuruAra.UrunGrupId"] = ""
        
        // Column parameters
        let columns = ["DuyuruTarihi", "FirmaAdi", "Marka", "UrunAdi", "Uygunsuzluk",
                      "PartiSeriNo", "FirmaIlce", "FirmaIl", "UrunGrupAdi"]
        
        for (index, column) in columns.enumerated() {
            params["columns[\(index)][data]"] = column
            params["columns[\(index)][name]"] = column
            params["columns[\(index)][searchable]"] = "true"
            params["columns[\(index)][orderable]"] = "true"
            params["columns[\(index)][search][value]"] = ""
            params["columns[\(index)][search][regex]"] = "false"
        }
        
        return params
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
            .data(using: .utf8)!
    }
    
    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371e3 // Earth's radius in meters
        let φ1 = lat1 * .pi / 180
        let φ2 = lat2 * .pi / 180
        let Δφ = (lat2 - lat1) * .pi / 180
        let Δλ = (lon2 - lon1) * .pi / 180
        
        let a = sin(Δφ/2) * sin(Δφ/2) +
                cos(φ1) * cos(φ2) *
                sin(Δλ/2) * sin(Δλ/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return R * c // Distance in meters
    }
} 