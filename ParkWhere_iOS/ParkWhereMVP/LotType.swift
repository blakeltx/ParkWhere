//
//  LotType.swift
//  ParkWhereMVP
//
//

import Foundation
import CoreLocation

enum LotType: String, Codable {
    case lot
    case garage
}

struct Coordinate: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}

extension String : Error {}

struct Lot: Hashable, Decodable {
    var title: String
    var type: LotType
    var location: Coordinate
    var garageCode: String?
    var visitor_slots: Int
    var address: String?
    var ev_slots: Int
    var total_slots: Int
    var disabled_slots: Int?
    
    // Get Data from Garage API
    private func fetchOccupancyData() async throws -> LotOccupancyData {
        guard let garageCode else {
            throw "Not a Surface Lot"
        }
        return try await URLSession.shared.decode(LotOccupancyData.self, from: URL(string: "https://transport.tamu.edu/ParkingFeed/api/lots/\(garageCode)")!)
    }
    
    
    func fetchOccupiedSlots() async -> Int {
        do {
            let data = try await self.fetchOccupancyData()
            return data.FAC_Occupied
        } catch {
            return 0
        }
    }
    
    /// Get occupancy ratio from garage api
    func fetchOccupancyRatio() async -> Double {
//        return Double.random(in: 0..<4)
        guard garageCode != nil else {
            do {
                return try await self.fetchAvgOccupancy()
            } catch {
                print("Error fetching CK Records for \(title)")
                print(error.localizedDescription)
                return 0.0
            }
        }
        
        // Get data from garage api
        do {
            let data = try await self.fetchOccupancyData()
            // Return Ratio
            return Double(data.FAC_Occupied) / Double(data.FAC_Capacity)
        } catch {
            return 0.0
        }
    }
}

/// Class to assist in getting Lot Occupancy async
@MainActor final class OccupancyGetter: ObservableObject {
    @Published private(set) var occupancy: Double = 0.0
    @Published private(set) var slots: Int = 0
    
    func fetchOccupancy(lot: Lot) async {
        self.occupancy = await lot.fetchOccupancyRatio()
    }
    
    func fetchSlots(lot: Lot) async {
        print("Fetching slots")
        self.slots = await lot.fetchOccupiedSlots()
    }
}

extension CLLocationCoordinate2D: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.latitude)
        hasher.combine(self.longitude)
    }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
    }
}

extension URLSession {
    /// Gets JSON data from url and returns it in a custom type
    func decode<T: Decodable>(
        _ type: T.Type = T.self,
        from url: URL,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) async throws  -> T {
        self.configuration.httpAdditionalHeaders = ["Accept": "application/json"]
        let (data, _) = try await data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw error
        }
    }
}

struct LotOccupancyData: Codable {
    let FAC_UID: Int
    let FAC_Code: String
    let FAC_Description: String
    let FAC_Capacity: Int
    let FAC_Occupied: Int
    let FAC_Available: Int
    let FAC_LastRefresh: String?
}
