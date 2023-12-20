//
//  HANE24Widget.swift
//  HANE24Widget
//
//  Created by Katherine JANG on 12/13/23.
//

import WidgetKit
import Foundation
import SwiftUI


struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    accTimes: MonthlyAccumulationTimes(totalAccumulationTime: 123456, acceptedAccumulationTime: 12345))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) { getMonthlyAccTime { times in
        let entry = SimpleEntry(date: Date(),
                                accTimes: MonthlyAccumulationTimes(totalAccumulationTime: times.totalAccumulationTime,
                                                                   acceptedAccumulationTime: times.acceptedAccumulationTime))
        completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) { getMonthlyAccTime { times in
        let currentDate = Date()
        let entry = SimpleEntry(date: Date(),
                                accTimes: MonthlyAccumulationTimes(totalAccumulationTime: times.totalAccumulationTime, 
                                                                   acceptedAccumulationTime: times.acceptedAccumulationTime))
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
        }
    }

    private func getMonthlyAccTime(completion: @escaping((MonthlyAccumulationTimes) -> Void)) {
        var components = URLComponents(string: "https://api-dev.24hoursarenotenough.42seoul.kr/v3/tag-log/getAllTagPerMonth")!
        let year = URLQueryItem(name: "year", value: "\(2023)")
        let month = URLQueryItem(name: "month", value: "\(12)")
        components.queryItems = [year, month]
        guard let token = getAccessToken() else {
            print("invalid Token")
            return
        }
        print("token: ", token)
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(String(describing: token))"
        ]
        URLSession.shared.dataTask(with: request) {data, _, _ in
            guard let data = data,
                  let accTimes = try? JSONDecoder().decode(MonthlyAccumulationTimes.self, from: data) else {
                return
            }
            completion(accTimes)
        }.resume()
    }

    private func getAccessToken() -> String? {
        return UserDefaults.shared.object(forKey: HaneWidgetConstant.storageKey) as? String
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let accTimes: MonthlyAccumulationTimes
}

struct HANE24WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        showAccTimes
    }

    var showAccTimes: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom, spacing: 7) {
                Text("24HANE")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: "#735BF2"))
                Text("\(entry.date.MM).\(entry.date.dd) \(entry.date.hourToString):\(entry.date.minuteToString) 기준")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.black.opacity(0.35))
            }

            HStack {
                Rectangle()
                    .frame(width: 2, height: 32)
                    .foregroundStyle(Color(hex: "#333333"))
                VStack(alignment: .leading) {
                    Text("월 누적 시간")
                        .font(.system(size: 15, weight: .semibold))
                    Text("\(entry.accTimes.totalAccumulationTime / 3600) 시간 \(entry.accTimes.totalAccumulationTime % 3600 / 60) 분")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.5))
                }
            }
            .padding(.top, 18)

            HStack {
                Rectangle()
                    .frame(width: 2, height: 32)
                    .foregroundStyle(Color(hex: "#735BF2"))
                VStack(alignment: .leading) {
                    Text("인정 시간")
                        .font(.system(size: 15, weight: .semibold))
                    Text("\(entry.accTimes.acceptedAccumulationTime / 3600) 시간 \(entry.accTimes.acceptedAccumulationTime % 3600 / 60) 분")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.5))
                }
            }
            .padding(.top, 12)
        }
    }
}

struct HANE24Widget: Widget {
    let kind: String = "HANE24Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HANE24WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("24HANE Widget")
        .description("총 체류시간 & 인정시간 제공")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    HANE24Widget()
} timeline: {
    SimpleEntry(date: .now, accTimes: MonthlyAccumulationTimes(totalAccumulationTime: 123456, acceptedAccumulationTime: 12345))
    SimpleEntry(date: .now, accTimes: MonthlyAccumulationTimes(totalAccumulationTime: 123456, acceptedAccumulationTime: 12345))
}
