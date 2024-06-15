//
//  CKHelper.swift
//  ParkWhereMVP
//
//  Created by William Hatcher on 4/24/23.
//

import CloudKit
import os

// MARK: Crowdsourcing Models
struct OccupancyReport: Hashable {
    var LotTitle: String
    var Occupancy: Double
}

enum ORKeys: String {
    case type = "SurfaceOccupancy"
    case LotTitle
    case Occupancy
}


extension OccupancyReport {
    var record: CKRecord {
        let record = CKRecord(recordType: ORKeys.type.rawValue)
        record[ORKeys.LotTitle.rawValue] = LotTitle
        record[ORKeys.Occupancy.rawValue] = Occupancy
        return record
    }
    
    init?(from record: CKRecord) {
        guard
            let LotTitle = record[ORKeys.LotTitle.rawValue] as? String,
            let Occupancy = record[ORKeys.Occupancy.rawValue] as? Double
        else { return nil }
        self = .init(LotTitle: LotTitle, Occupancy: Occupancy)
    }
}

// MARK: CloudKit Helper Code
final class CloudKitService {
    private static let logger = Logger(
        subsystem: "com.aaplab.fastbot",
        category: String(describing: CloudKitService.self)
    )

    func checkAccountStatus() async throws -> CKAccountStatus {
        try await CKContainer.default().accountStatus()
    }
    
    func save(_ record: CKRecord) async throws {
        try await CKContainer(identifier: "iCloud.SurfaceLotCrowdSourcedData").publicCloudDatabase.save(record)
    }
}

extension Lot {
    func fetchAvgOccupancy() async throws -> Double {
        let predicate = NSPredicate(
            format: "\(ORKeys.LotTitle.rawValue) == %@", self.title)
        let query = CKQuery(
            recordType: ORKeys.type.rawValue,
            predicate: predicate)
        let result = try await CKContainer(identifier: "iCloud.SurfaceLotCrowdSourcedData").publicCloudDatabase.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        let oc_rec = records.compactMap(OccupancyReport.init)
        let oc_sum = oc_rec.reduce(0, {$0 + $1.Occupancy})
        let oc_avg = oc_sum / Double(oc_rec.count)
        print(self.title, oc_avg)
        return oc_avg
    }
}
