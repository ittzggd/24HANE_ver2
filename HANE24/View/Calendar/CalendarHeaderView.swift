//
//  CalendarHeaderView.swift
//  24HANE
//
//  Created by Katherine JANG on 12/15/23.
//

import SwiftUI

struct CalendarHeaderView: View {
    @Binding var picker: Bool
    @EnvironmentObject var hane: Hane

    var body: some View {
        HStack {
            changeMonthButton(isForward: false)
                .disabled(hane.selectedDate.toString("yyyy.MM") <= "2022.08" || hane.loading)
            Spacer()
            Text("\(hane.selectedDate.yearToString).\(hane.selectedDate.monthToString)")
                .foregroundColor(picker ? .gradientPurple : .fontDefault )
                .onTapGesture {
                    picker.toggle()
                }
            Spacer()
            changeMonthButton(isForward: true)
                .disabled(hane.selectedDate.toString("yyyy.MM") >= Date().toString("yyyy.MM") || hane.loading)
        }
        .font(.system(size: 20, weight: .semibold))
    }

    @ViewBuilder func changeMonthButton(isForward: Bool) -> some View {
        Button {
            hane.selectedDate = Calendar.current.date(byAdding: .month, value: isForward ? 1 : -1, to: hane.selectedDate)!
        } label: {
            ZStack {
                Image(systemName: isForward ? "chevron.right" : "chevron.left")
                    .resizable()
                    .frame(width: 8, height: 12)
            }
            .frame(width: 15, height: 15)
        }
    }
}

#Preview {
    CalendarHeaderView(picker: .constant(false))
        .environmentObject(Hane())
}
