//
//  JSONs.swift
//  HANE24
//
//  Created by Yunki on 2023/02/17.
//

import Foundation

struct InOutLog: Codable {
    let inTimeStamp: Int64?
    let outTimeStamp: Int64?
    let durationSecond: Int64?
}

struct PerDay: Codable {
    let login: String
    let profileImage: String
    let inOutLogs: [InOutLog]
}

struct PerMonth: Codable {
    let login: String
    let profileImage: String
    let inOutLogs: [InOutLog]
}

struct MainInfo: Codable {
    let login: String
    let profileImage: String
    let isAdmin: Bool
    let inoutState: String
    let tagAt: String?
    let gaepo: Int
    let seocho: Int
}

struct AccumulationTimes: Codable {
    let todayAccumulationTime: Int64
    let monthAccumulationTime: Int64
    let sixWeekAccumulationTime: [Double]
    let sixMonthAccumulationTime: [Double]
}

struct ReissueState: Codable {
    let state: String
}


// for CoreData
public class InOutLogs: NSSecureUnarchiveFromDataTransformer {
    var data: [InOutLog]
    
    init(data: [InOutLog]) {
        self.data = data
    }
}
