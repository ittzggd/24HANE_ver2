//
//  HaneVM.swift
//  HANE24
//
//  Created by Yunki on 2023/02/17.
//

import Foundation
import WebKit

enum MyError: Error {
    case tokenExpired(String)
}

enum CardState {
    case none
    case apply
    case inProgress
    case pickUpRequested
    case done
}

class Hane: ObservableObject {
    /// 기본정보
    @Published var isInCluster: Bool
    @Published var profileImage: String
    @Published var loginID: String
    @Published var clusterPopulation: Int

    /// 안내메세지
    @Published var fundInfoNotice: Notice
    @Published var tagLatencyNotice: Notice

    /// 누적시간데이터
    @Published var dailyAccumulationTime: Int64 = 0
    @Published var monthlyAccumulationTime: Int64 = 0
    @Published var sixWeekAccumulationTime: [Double] = Array(repeating: 0, count: 6)
    @Published var sixMonthAccumulationTime: [Double] = Array(repeating: 0, count: 6)

    /// 누적인정시간
    /// For HomeView
    @Published var thisMonthAcceptedAccumulationTime: Int64 = 0
    /// For CalendarView
    @Published var monthlyTotalAccumulationTime: Int64 = 0
    @Published var monthlyAcceptedAccumulationTime: Int64 = 0

    /// 현재 로그인(인증) 여부
    @Published var isSignIn: Bool = false

    /// 선택한 달의 태깅데이터 / 일자별 합산시간
    @Published var monthlyLogs: [String: [InOutLog]] = [:]
    @Published var dailyTotalTimesInAMonth: [Int64] = Array(repeating: 0, count: 32)

    /// 로딩화면여부
    @Published var loading: Bool = true

    /// 카드 재발급 상태
    @Published var reissueState: CardState = .none
    
    /// 선택일자
    @Published var selectedDate: Date = .now

    /// Model
    var inOutLog: InOutLog
    var perMonth: PerMonth
    var mainInfo: MainInfo
    var accumulationTimes: AccumulationTimes
    var cardReissueState: ReissueState

    var APIroot: String

    var timer: Timer?

    init() {
        self.isInCluster = false
        self.profileImage = ""
        self.loginID = ""
        self.clusterPopulation = 0

        self.fundInfoNotice = Notice(title: "", content: "")
        self.tagLatencyNotice = Notice(title: "", content: "")

        self.inOutLog = InOutLog(inTimeStamp: nil, outTimeStamp: nil, durationSecond: nil)
        self.perMonth = PerMonth(login: "", profileImage: "", inOutLogs: [], totalAccumulationTime: 0, acceptedAccumulationTime: 0)
        self.mainInfo = MainInfo(
            login: "",
            profileImage: "",
            isAdmin: false,
            inoutState: "",
            tagAt: nil,
            gaepo: 0,
            infoMessages:
                InfoMessages(
                    fundInfoNotice: InfoMessage(title: "", content: ""),
                    tagLatencyNotice: InfoMessage(title: "", content: "")
                )
        )
        self.accumulationTimes = AccumulationTimes(
            todayAccumulationTime: 0,
            monthAccumulationTime: 0,
            sixWeekAccumulationTime: Array(repeating: 0, count: 6),
            sixMonthAccumulationTime: Array(repeating: 0, count: 6),
            monthlyAcceptedAccumulationTime: 0
        )

        self.APIroot = "https://" + (Bundle.main.infoDictionary?["API_URL"] as? String ?? "wrong")
        self.reissueState = .none
        self.cardReissueState = ReissueState(state: "none")

        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard self.isInCluster else { return }
            self.dailyAccumulationTime += 1
        }
    }

    @MainActor
    func refresh() async throws {
        do {
            try await updateMainInfo()
            try await updateAccumulationTime()
            try await updateMonthlyLogs(date: selectedDate)
        } catch {
            self.isSignIn = false
        }
    }

    func signOut() {
        WKWebsiteDataStore
            .default()
            .fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: { (records) -> Void in
                for record in records {
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            })
        UserDefaults.standard.removeObject(forKey: "Token")
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
            return
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
        self.isInCluster = mainInfo.inoutState == "IN" ? true : false
        self.clusterPopulation = mainInfo.gaepo

        self.fundInfoNotice = Notice(
            title: mainInfo.infoMessages.fundInfoNotice.title,
            content: mainInfo.infoMessages.fundInfoNotice.content
        )
        self.tagLatencyNotice = Notice(
            title: mainInfo.infoMessages.tagLatencyNotice.title,
            content: mainInfo.infoMessages.tagLatencyNotice.content
        )

        self.loading = false
    }

    @MainActor
    func updateAccumulationTime() async throws {
        self.loading = true

        try await callAccumulationTimes()

        self.dailyAccumulationTime = self.accumulationTimes.todayAccumulationTime
        self.monthlyAccumulationTime = self.accumulationTimes.monthAccumulationTime
        self.sixWeekAccumulationTime = self.accumulationTimes.sixWeekAccumulationTime
        self.sixMonthAccumulationTime = self.accumulationTimes.sixMonthAccumulationTime
        self.thisMonthAcceptedAccumulationTime = self.accumulationTimes.monthlyAcceptedAccumulationTime

        self.loading = false
    }
    /**
     fetch
     if isLogExist
        if needUpdate
            apicall
        else
            -
     else
        apicall
     */
    @MainActor
    func updateMonthlyLogs(date: Date) async throws {
        // update MonthlyLogs
        self.loading = true

        try await callPerMonth(year: date.yearToInt, month: date.monthToInt)

        self.monthlyLogs = Dictionary(grouping: perMonth.inOutLogs) {
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

        self.monthlyTotalAccumulationTime = self.perMonth.totalAccumulationTime
        self.monthlyAcceptedAccumulationTime = self.perMonth.acceptedAccumulationTime

        self.loading = false
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
            "Authorization": "Bearer \(String(describing: token))"
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
            "Authorization": "Bearer \(String(describing: token) )"
        ]
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MyError.tokenExpired("get new token!")
        }
        let decodedData =  try JSONDecoder().decode(type.self, from: data)
        return decodedData
    }

    func postJsonAsync() async throws {
        let urlString = APIroot + "/v2/reissue/request"
        guard let url = URL(string: urlString) else {
            fatalError("missingURL")
        }
        guard let token = UserDefaults.standard.string(forKey: "Token") else {
            fatalError("UnValid Token")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(String(describing: token) )"
        ]

        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 201 else {
            throw MyError.tokenExpired("get new token!")
        }
    }

    func patchJsonAsync() async throws {
        let urlString = APIroot + "/v2/reissue/finish"
        guard let url = URL(string: urlString) else {
            fatalError("missingURL")
        }
        guard let token = UserDefaults.standard.string(forKey: "Token") else {
            fatalError("UnValid Token")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(String(describing: token) )"
        ]

        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MyError.tokenExpired("get new token!")
        }
    }

    func callAccumulationTimes() async throws {
        self.accumulationTimes = try await callJsonAsync(APIroot + "/v3/tag-log/accumulationTimes", type: AccumulationTimes.self)
    }

    func callMainInfo() async throws {
        self.mainInfo = try await callJsonAsync(APIroot + "/v3/tag-log/maininfo", type: MainInfo.self)
    }

    func callPerMonth(year: Int, month: Int) async throws {
        var components = URLComponents(string: APIroot + "/v3/tag-log/getAllTagPerMonth")!
        let year = URLQueryItem(name: "year", value: "\(year)")
        let month = URLQueryItem(name: "month", value: "\(month)")
        components.queryItems = [year, month]

        self.perMonth = try await callJsonAsync(components.url!.absoluteString, type: PerMonth.self)
    }

    func callReissue() async throws {
        self.cardReissueState = try await callJsonAsync(APIroot + "/v2/reissue", type: ReissueState.self)
    }
}
