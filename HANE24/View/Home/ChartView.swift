//
//  ChartView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/13/23.
//

import SwiftUI
import Charts

func getRatio(data: Array<Double>) -> Array<Double> {
    var retArray: Array<Double> = []
    let max: Double = data.max() != 0 ? data.max()! : 1
    for i in 0..<6 {
        let ratio: Double = (data[i] / max)
        retArray.append(ratio)
    }
    return retArray
}

struct ChartView: View {
    @State var selectedChart = 0
    var item: ChartItem
    var ratData: Array<Double> {
        get{
            return getRatio(data: item.data)
        }
    }

    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.white)
            VStack(alignment: .center) {
                HStack{
                    Text("\(item.title)")
                        .foregroundColor(.black)
                        .font(.system(size: 14, weight: .semibold))
                    Text("(6\(item.id))")
                        .foregroundColor(.textGray)
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 30)
                .padding(.bottom, 10)
                ChartDetailView(selectedChart: $selectedChart, id: item.id, time: item.data[selectedChart], period: item.period[selectedChart])
                    .frame(width: 290, height: 60)
                    .padding(.bottom)
                HStack(alignment: .bottom) {
                    ForEach(0..<ratData.count, id: \.self) { index in
                        Button{
                            selectedChart = index
                        } label: {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width:25, height: 6 + 81 * ratData[index])
                                    .padding(.horizontal, 4)
                                    .foregroundStyle(
                                        LinearGradient(gradient: Gradient(colors: [.gradientBlue, .gradientPurple]), startPoint: .top, endPoint: .bottom)
                                    )
                            }
                                
                        }
                    }
                }
                HStack{
                    Text("최신순")
                    Spacer()
                    Text("오래된순")
                }
                .foregroundColor(Color(hex: "#9B9797"))
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 60)
                .padding(.bottom, 20)
            }
        }
        
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(item: ChartItem(id: "주", title: "최근 주간 그래프", period: ["1.2(월)-1.8(일)","1.9(월)-1.15(일)","1.16(월)-1.22(일)","1.23(월)-1.29(일)","1.30(월)-2.5(일)", "2.6(월)-2.12(일)"], data:  [1234, 5678, 9012, 3456, 7890, 1234]))
    }
}
