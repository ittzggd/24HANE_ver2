//
//  TagLogView.swift
//  HANE24
//
//  Created by Yunki on 2023/02/16.
//

import SwiftUI

struct TagLogView: View {
    @EnvironmentObject var hane: Hane
    @Environment(\.colorScheme) var colorScheme

    var logList: [Log]

    var body: some View {
        let dailyTotalTime = hane.dailyTotalTimesInAMonth[hane.selectedDate.dayToInt]
        VStack(alignment: .center, spacing: 4) {
            HStack {
                Text("\(hane.selectedDate.monthToInt).\(hane.selectedDate.dayToInt) \(hane.selectedDate.toString("E"))요일")
                    .padding(.leading, 5)
                Spacer()
                Text("\(dailyTotalTime / 3600)시간 \((dailyTotalTime % 3600) / 60)분")
                    .padding(.trailing, 5)
            }
            .font(.system(size: 14, weight: .medium, design: .default))
            .foregroundColor(colorScheme == .light ? Color.gray : Color(hex: "EAEAEA"))

            Divider()
                .padding(.bottom, 2)

            HStack {
                Text("입실")
                    .frame(width: 65, height: 24)

                Spacer()

                Text("퇴실")
                    .frame(width: 65, height: 24)

                Spacer()

                Text("체류시간")
                    .frame(width: 65, height: 24)
            }
            .foregroundColor(colorScheme == .dark ? .white : .DarkDefaultBG)
            .font(.system(size: 14, weight: .bold))

            if logList.isEmpty {
                Text("기록이 없습니다.")
                    .foregroundColor(colorScheme == .light ? .chartDetailBG : .white)
                    .font(.system(size: 13, weight: .light))
                    .padding(.vertical, 5)
            } else {
                ScrollView {
                    ForEach(logList, id: \.self) { log in
                        tagLog(log)
                    }
                }
                .frame(maxHeight: 230)
            }
        }
    }

    @ViewBuilder
    func tagLog(_ log: Log) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(colorScheme == .dark ? Color(hex: "555555") : Color(hex: "#EAEAEA"))
                .frame(height: 24)
                .isHidden((log.logTime != "누락"))

            HStack {
                Text(log.inTime ?? "-")
                    .frame(width: 65, height: 24)

                Spacer()

                Text(log.outTime ?? "-")
                    .frame(width: 65, height: 24)

                Spacer()

                Text(log.logTime ?? "누락")
                    .frame(width: 65, height: 24)
            }
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(colorScheme == .light ? .chartDetailBG : .white)
        }
    }
}

#Preview {
    TagLogView(logList: [])
        .environmentObject(Hane())
}
