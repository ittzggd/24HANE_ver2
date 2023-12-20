//
//  CalendarGridView.swift
//  HANE24
//
//  Created by Yunki on 2023/02/16.
//

import SwiftUI

struct CalendarGridView: View {
    @Binding var picker: Bool

    @EnvironmentObject var hane: Hane

    let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    let cols: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 7)

    var body: some View {
        ZStack {
            LoadingAnimation()
                .isHidden(!hane.loading)
            VStack {
                // day of week
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(weekdays, id: \.self) { dayOfWeek in
                        Text("\(dayOfWeek)")
                            .foregroundColor(.fontDisabled)
                            .font(.system(size: 13, weight: .light))
                    }
                }

                // days with color
                // is future ? disabled
                // is selected ? Circle with white font
                // is today ? border only
                // default
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(hane.selectedDate.daysOfMonth.indices, id: \.self) { d in
                        if let day = hane.selectedDate.daysOfMonth[d] {
                            Button {
                                hane.selectedDate = day
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: day.isSameDate(with: hane.selectedDate) ? 20 : 10)
                                        .foregroundColor(getGridColor(day))
                                        .overlay {
                                            if day.isSameDate(with: Date())
                                                && !day.isSameDate(with: hane.selectedDate) {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.dateToday, lineWidth: 1)
                                            }
                                        }
                                        .isHidden(day > Date.now)

                                    Text("\(day.dayToInt)")
                                        .foregroundColor(getTextColor(day))
                                        .font(.system(size: 14, weight: day.isSameDate(with: hane.selectedDate) ? .bold : .regular))
                                }
                            }
                            .frame(width: 30, height: 30)
                            .disabled(day > Date.now)
                        } else {
                            Text("")
                        }
                    }
                }
                .isHidden(hane.loading)
            }
        }
    }

    func getGridColor(_ day: Date) -> Color {
        switch day {
        case day where day.isSameDate(with: hane.selectedDate):
            return .dateSelected
        case day where day.isSameDate(with: Date.now):
            return .backgroundCalendar
        default:
            return calculateLogColor(accumulationTime: hane.dailyTotalTimesInAMonth[day.dayToInt])
        }
    }

    func getTextColor(_ day: Date) -> Color {
        switch day {
        case day where day > Date.now:
            return .fontDisabled
        case day where day.isSameDate(with: hane.selectedDate):
            return .fontWhite
        case day where day.isSameDate(with: Date.now):
            return .dateToday
        default:
            return .fontDefault
        }
    }

    func calculateLogColor(accumulationTime: Int64) -> Color {
        switch accumulationTime {
        case 0:
            return .backgroundCalendar
        case 1 ... 14400:
            return .dateBackgroundLevel1
        case 14400 ... 28800:
            return .dateBackgroundLevel2
        case 28800 ... 43200:
            return .dateBackgroundLevel3
        default:
            return .dateBackgroundLevel4
        }
    }

}

#Preview {
    CalendarGridView(picker: .constant(false))
        .environmentObject(Hane())
}
