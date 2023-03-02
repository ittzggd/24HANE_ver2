//
//  Structs.swift
//  HANE24
//
//  Created by Yunki on 2023/02/16.
//

import Foundation

/// TagLogView
struct Log: Hashable {
    var inTime: String?
    var outTime: String?
    var logTime: String?
}

/// ChartView
struct ChartItem: Identifiable {
    var id: String
    var title: String
    var period: Array<String>
    var data: Array<Double>
}

/// PopulationView
struct ClusterPopulation {
    var gaepo: Int
    var seocho: Int
}

/// MoreView
struct MoreItem: Identifiable {
    var id: UUID
    var title: String
    var url: String
    var image: String
}
