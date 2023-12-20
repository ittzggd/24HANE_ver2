//
//  ChartDetailView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/13/23.
//

import SwiftUI

func  numOfDays(selection: Int) -> Double {
    let date =  Calendar.current.date(byAdding: .month, value: -selection, to: Date())!
    return Double(date.numberOfDays)
}

struct ChartDetailView: View {
    @Binding var selectedChart: Int
    var id: String
    var time: Double
    var period: String
    var body: some View {
        ZStack {
            VStack(spacing: -3) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.chartDetailBG)
                    .frame(height: 60)
                HStack {
                    ForEach(0..<6) { idx in
                            ZStack {
                                Rectangle()
                                    .frame(width: 25)
                                    .hidden()
                                Image(systemName: "arrowtriangle.down.fill")
                                    .foregroundColor(.chartDetailBG)
                                    .opacity(idx == selectedChart ? 1 : 0)
                            }
                            .padding(.horizontal, 4)
                        }
                }

            }
            VStack {
                HStack {
                    Text(period)
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .semibold))
                    Spacer()
                    /// 소수점 아래 1자리까지 시간 단위로 표기 (내림처리)
                    Text("총 \(floor(time / 360) / 10, specifier: "%.1f")시간")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .semibold))

                }
                .padding(.bottom, 2)
                HStack {
                    Spacer()
                    Text("일 평균")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .semibold))
                    if id == "주" {
                        Text("\(floor(time / 360) / 70, specifier: "%.1f")시간")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .semibold))
                    } else {
                        Text("\((floor(time / 360) / 10) / (numOfDays(selection: selectedChart)), specifier: "%.1f")시간")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .semibold))
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.leading)
            .padding(.trailing)
        }
    }
}

#Preview {
    ChartDetailView(selectedChart: .constant(3), id: "월", time: 1800, period: "1.2(월)-1.8(일)")
}
