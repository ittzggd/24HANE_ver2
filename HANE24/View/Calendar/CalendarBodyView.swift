//
//  CalendarBodyView.swift
//  24HANE
//
//  Created by Katherine JANG on 12/15/23.
//

import SwiftUI

struct CalendarBodyView: View {
    @EnvironmentObject var hane: Hane
    @State var picker = false
    @State var datePickerSelection: Date

    var dateRange: ClosedRange<Date> {
        let min = Date(2022, 8, 1)
        let max = Date()
        return min...max
    }

    var body: some View {
        VStack {
            CalendarHeaderView(picker: $picker)
                .padding(10)
                .padding(.bottom, 8)
            ZStack {
                if !picker {
                    CalendarGridView(picker: $picker)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.backgroundCalendar)

                        DatePicker(
                            "Date",
                            selection: $datePickerSelection,
                            in: dateRange,
                            displayedComponents: [.date])
                        .datePickerStyle(WheelDatePickerStyle())
                    }
                    .frame(maxWidth: 100)
                }
            }
        }
        .onChange(of: picker) {pickerState in
            if !pickerState {
                hane.selectedDate = datePickerSelection
            }
        }
    }
}

#Preview {
    CalendarBodyView(datePickerSelection: Date())
        .environmentObject(Hane())
}
