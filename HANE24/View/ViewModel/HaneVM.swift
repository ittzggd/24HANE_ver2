//
//  HaneVM.swift
//  HANE24
//
//  Created by Yunki on 2023/02/17.
//

import Foundation
import WebKit
import CoreData

enum MyError: Error {
    case tokenExpired(String)
}

enum cardState {
    case none
    case apply
    case inProgress
    case pickUpRequested
    case done
}


class Hane: ObservableObject {
    @Published var inOutState: Bool
    @Published var profileImage: String
    @Published var loginID: String
    @Published var clusterPopulation: ClusterPopulation
    
    @Published var dailyAccumulationTime: Int64 = 0
    @Published var monthlyAccumulationTime: Int64 = 0
    @Published var sixWeekAccumulationTime: [Double] = Array(repeating: 0, count: 6)
    @Published var sixMonthAccumulationTime: [Double] = Array(repeating: 0, count: 6)
    
    @Published var isSignIn: Bool = false
    
    @Published var monthlyLogs: [String: [InOutLog]] = [:]
    @Published var dailyTotalTimesInAMonth: [Int64] = Array(repeating: 0, count: 32)
    
    @Published var loading: Bool = true
    
    @Published var reissueState: cardState = .none
    
    var monthlyLogController = MonthlyLogController.shared
    
    var inOutLog: InOutLog
    var perMonth: PerMonth
    var mainInfo: MainInfo
    var accumulationTimes: AccumulationTimes
    var cardReissueState: ReissueState
    
    var APIroot: String
    
    init() {
        self.inOutState = false
        self.profileImage = "cabi"
        self.loginID = ""
        self.clusterPopulation = ClusterPopulation(gaepo: 0, seocho: 0)
        
        self.dailyAccumulationTime = 0
        self.monthlyAccumulationTime = 0
        self.sixWeekAccumulationTime = Array(repeating: 0, count: 6)
        self.sixMonthAccumulationTime = Array(repeating: 0, count: 6)
        
        self.isSignIn = false
        self.monthlyLogs = [:]
        self.dailyTotalTimesInAMonth = Array(repeating: 0, count: 32)
        
        self.inOutLog = InOutLog(inTimeStamp: nil, outTimeStamp: nil, durationSecond: nil)
        self.perMonth = PerMonth(login: "", profileImage: "", inOutLogs: [])
        self.mainInfo = MainInfo(login: "", profileImage: "", isAdmin: false, inoutState: "", tagAt: nil, gaepo: 0, seocho: 0)
        self.accumulationTimes = AccumulationTimes(todayAccumulationTime: 0, monthAccumulationTime: 0, sixWeekAccumulationTime: Array(repeating: 0, count: 6), sixMonthAccumulationTime: Array(repeating: 0, count: 6))

        self.APIroot = "https://" + (Bundle.main.infoDictionary?["API_URL"] as? String ?? "wrong")
        self.reissueState = .none
        self.cardReissueState = ReissueState(state: "in_progress")
    }
    
    @MainActor
    func refresh(date: Date) async throws {
        do {
            try await updateMainInfo()
            try await updateAccumulationTime()
            try await updateMonthlyLogs(date: date)
            try await updateReissueState()
        } catch {
            self.isSignIn = false
        }
    }
    
    func SignOut() {
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: {
                    (records) -> Void in
                    for record in records{
                        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                    }
                })
        UserDefaults.standard.removeObject(forKey: "Token")
        self.monthlyLogController.resetLogs()
        self.isSignIn = false
    }
}

// update Published
extension Hane {
    
    @MainActor
    func updateReissueState() async throws {
        do {
            try await callReissue()
        } catch {
            self.reissueState = .none
        }
        switch cardReissueState.state {
        case "none":
            self.reissueState = .none
        case "apply":
            self.reissueState = .apply
        case "in_progress":
            self.reissueState = .inProgress
        case "pick_up_requested":
            self.reissueState = .pickUpRequested
        default:
            self.reissueState = .done
        }
    }
    
    @MainActor
    func updateMainInfo() async throws {
        self.loading = true
        
        try await callMainInfo()
        
        self.loginID = mainInfo.login
        self.profileImage = mainInfo.profileImage
        self.inOutState = mainInfo.inoutState == "IN" ? true : false
        self.clusterPopulation.gaepo = mainInfo.gaepo
        self.clusterPopulation.seocho = mainInfo.seocho
        
        self.loading = false
    }
    
    @MainActor
    func updateAccumulationTime() async throws {
        self.loading = true
        
        try await callAccumulationTimes()
        
        self.dailyAccumulationTime = self.accumulationTimes.todayAccumulationTime
        self.monthlyAccumulationTime = self.accumulationTimes.todayAccumulationTime
        self.sixWeekAccumulationTime = self.accumulationTimes.sixWeekAccumulationTime
        self.sixMonthAccumulationTime = self.accumulationTimes.sixMonthAccumulationTime
        
        self.loading = false
    }
    /**
     fetch
     if isLogExist
        if needUpdate
            apicall
            coredata.update
        else
            -
     else
        apicall
        coredata.add
     */
    @MainActor
    func updateMonthlyLogs(date: Date) async throws {
        // update MonthlyLogs
        self.monthlyLogController.fetchLogs()

        if let filteredLog = monthlyLogController.totalLogs.first(where:{$0.date == date.toString("yyyy.MM")}) {
            if filteredLog.needUpdate {
                self.monthlyLogs = Dictionary(grouping: filteredLog.inOutLogs!.data) {
                    Date(milliseconds: $0.inTimeStamp ?? $0.outTimeStamp!).toString("yyyy.MM.dd")
                }
                
                // update Daily Total Accumulation Times (CalendarView)
                self.dailyTotalTimesInAMonth = Array(repeating: 0, count: 32)
                for dailyLog in monthlyLogs {
                    var sum: Int64 = 0
                    for log in dailyLog.value {
                        sum += log.durationSecond ?? 0
                    }
                    self.dailyTotalTimesInAMonth[Int(dailyLog.key.split(separator: ".")[2]) ?? 0] = sum
                }
                
                try await callPerMonth(year: date.yearToInt, month: date.monthToInt)
                
                monthlyLogController.updateLogs(entity: filteredLog, inOutLogs: self.perMonth.inOutLogs, needUpdate: date.toString("yyyy.MM") >= Date().toString("yyyy.MM"))
                
                self.monthlyLogs = Dictionary(grouping: perMonth.inOutLogs) {
                    Date(milliseconds: $0.inTimeStamp ?? $0.outTimeStamp!).toString("yyyy.MM.dd")
                }
            } else {
                self.monthlyLogs = Dictionary(grouping: filteredLog.inOutLogs!.data) {
                    Date(milliseconds: $0.inTimeStamp ?? $0.outTimeStamp!).toString("yyyy.MM.dd")
                }
            }
        } else {
            self.loading = true
            try await callPerMonth(year: date.yearToInt, month: date.monthToInt)
            self.loading = false
            
            monthlyLogController.addLogs(date: date.toString("yyyy.MM"), inOutLogs: self.perMonth.inOutLogs, needUpdate: date.toString("yyyy.MM") >= Date().toString("yyyy.MM"))
            
            self.monthlyLogs = Dictionary(grouping: perMonth.inOutLogs) {
                Date(milliseconds: $0.inTimeStamp ?? $0.outTimeStamp!).toString("yyyy.MM.dd")
            }
        }
                
        // update Daily Total Accumulation Times (CalendarView)
        self.dailyTotalTimesInAMonth = Array(repeating: 0, count: 32)
        for dailyLog in monthlyLogs {
            var sum: Int64 = 0
            for log in dailyLog.value {
                sum += log.durationSecond ?? 0
            }
            self.dailyTotalTimesInAMonth[Int(dailyLog.key.split(separator: ".")[2]) ?? 0] = sum
        }

    }
}

// Call APIs
extension Hane {
    @MainActor
    func isLogin() async throws -> Bool {
        guard let url = URL(string: APIroot + "/user/login/islogin") else {
            fatalError("MissingURL")
        }
        guard let token = UserDefaults.standard.string(forKey: "Token") else {
            return false
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Authorization" : "Bearer \(String(describing: token))"
        ]
        let (_, response) = try await URLSession.shared.data(for: request)
        if (response as? HTTPURLResponse)?.statusCode == 204 {
            return true
        } else {
            return false
        }
    }
    
    private func callJsonAsync<T>(_ url: String, type: T.Type) async throws -> T where T: Decodable {
        guard let url = URL(string: url) else {
            fatalError("MissingURL")
        }
        guard let token = UserDefaults.standard.string(forKey: "Token") else {
            fatalError("UnValid Token")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Authorization" : "Bearer \(String(describing: token) )"
        ]
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MyError.tokenExpired("get new token!")
        }
        let decodedData =  try JSONDecoder().decode(type.self, from: data)
        return decodedData
    }
    
    func postJsonAsync() async throws {
        let urlString = APIroot + "/v1/reissue/request"
        guard let url = URL(string: urlString) else {
            fatalError("missingURL")
        }
        guard let token = UserDefaults.standard.string(forKey: "Token") else {
            fatalError("UnValid Token")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization" : "Bearer \(String(describing: token) )"
        ]
        
        let (_ , response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 201 else {
            throw MyError.tokenExpired("get new token!")
        }
    }
    
    func patchJsonAsync() async throws {
        let urlString = APIroot + "/v1/reissue/finish"
        guard let url = URL(string: urlString) else {
            fatalError("missingURL")
        }
        guard let token = UserDefaults.standard.string(forKey: "Token") else {
            fatalError("UnValid Token")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.allHTTPHeaderFields = [
            "Authorization" : "Bearer \(String(describing: token) )"
        ]
        
        let (_ , response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 201 else {
            throw MyError.tokenExpired("get new token!")
        }
    }
    
    func callAccumulationTimes() async throws {
        self.accumulationTimes = try await callJsonAsync(APIroot + "/v1/tag-log/accumulationTimes", type: AccumulationTimes.self)
    }
    
    func callMainInfo() async throws {
        self.mainInfo = try await callJsonAsync(APIroot + "/v1/tag-log/maininfo", type: MainInfo.self)
    }
    
    func callPerMonth(year: Int, month: Int) async throws {
        var components = URLComponents(string: APIroot + "/v1/tag-log/getAllTagPerMonth")!
        let year = URLQueryItem(name: "year", value: "\(year)")
        let month = URLQueryItem(name: "month", value: "\(month)")
        components.queryItems = [year, month]
        
        self.perMonth = try await callJsonAsync(components.url!.absoluteString, type: PerMonth.self)
    }
    
    func callReissue() async throws {
        self.cardReissueState = try await callJsonAsync(APIroot + "/v1/reissue", type: ReissueState.self)
    }
}
