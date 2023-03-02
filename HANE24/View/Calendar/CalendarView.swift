//
//  CalendarView.swift
//  HANE24
//
//  Created by Yunki on 2023/02/15.
//

import SwiftUI

/// selectedDate: Date = 선택 날짜
struct CalendarView: View {
    @EnvironmentObject var hane: Hane
    @State var selectedDate: Date = Date()
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        ZStack {
            Theme.CalendarBackgoundColor(forScheme: colorScheme)
                .edgesIgnoringSafeArea(colorScheme == .dark ? .all : .top)
            ScrollView{
                PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                    ///[FixMe]
                    Task{
                        try await hane.refresh(date: selectedDate)
                    }
                }
                VStack(spacing: 16) {
                    CalendarGridView(selectedDate: $selectedDate)
                        .padding(.horizontal, 5)
                    AccTimeCardForCalendarView(totalAccTime: hane.dailyTotalTimesInAMonth.reduce(0, +))
                        .padding(.vertical, 10)
                    TagLogView(selectedDate: $selectedDate, logList: convert(hane.monthlyLogs[selectedDate.toString("yyyy.MM.dd")] ?? []))
                        .padding(.top, 10)
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
            .coordinateSpace(name: "pullToRefresh")
        }
        .coordinateSpace(name: "pullToRefresh")
    }
    
    func convert(_ from: [InOutLog]) -> [Log] {
        guard !from.isEmpty else { return [] }
        var logArray = from.map {
            var inTime: String? = nil
            var outTime: String? = nil
            var logTime: String? = "누락"
            if let intime = $0.inTimeStamp {
                inTime = Date(milliseconds: intime).toString("HH:mm:ss")
            }
            if let outtime = $0.outTimeStamp {
                outTime = Date(milliseconds: outtime).toString("HH:mm:ss")
            }
            if var logtime = $0.durationSecond {
                logtime -= 9 * 3600
                logTime = Date(milliseconds: logtime).toString("HH:mm:ss")
            }
            return Log(inTime: inTime, outTime: outTime, logTime: logTime)
        }
        logArray[0].logTime = (logArray[0].logTime == "누락" && selectedDate == Date()) ? "-" : logArray[0].logTime
        return logArray.reversed()
    }
}

/// String to Date
/// - Parameter format: yyyy.MM.dd
/// - Returns: date(yyyy.MM.dd)
func theDate(_ format: String) -> Date {
    let tmp = DateFormatter()
    tmp.dateFormat = "yyyy.MM.dd"
    return tmp.date(from: format)!
}

struct CalendarView_Previews: PreviewProvider {
    
    static var previews: some View {
        CalendarView(selectedDate: theDate("2023.03.31"))
            .environmentObject(Hane())
    }
}
