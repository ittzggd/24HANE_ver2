//
//  HomeView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/13/23.
//

import SwiftUI

struct chartItem: Identifiable {
    var id: String
    var title: String
    var period: Array<String>
    var data: Array<Double>
}

var items: [chartItem] = [
    chartItem(id: "주", title: "최근 주간 그래프", period: ["1.2(월)-1.8(일)","1.9(월)-1.15(일)","1.16(월)-1.22(일)","1.23(월)-1.29(일)","1.30(월)-2.5(일)","2.6(월)-2.12(일)"], data:  [42, 20, 41, 33, 59, 50]),
    chartItem(id: "월", title: "최근 월간 그래프", period: ["2023.2","2023.1","2022.12","2022.11","2022.10", "2022.10"], data:  [132, 100, 121, 123, 139, 120])
]


struct HomeView: View {
    init() {
          UIPageControl.appearance().currentPageIndicatorTintColor = .systemPurple
          UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.2)
    }
    var body: some View {
        NavigationView{
           ZStack{
               Color.defaultBG
               ScrollView{
                    VStack(alignment: .center, spacing: 16){
                        HStack(alignment: .center){
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .padding(.trailing, 3)
                            Text("hejang")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            Text("님")
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                            Spacer()
                            NavigationLink(destination: notificationView()) {
                                Image(systemName: "bell")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.iconColor)
                            }
                            .navigationBarHidden(true)
                            .frame(width: 24, height: 24)
                        }
                        .frame(height: 94)
                        .padding(.horizontal, 30)

                        AccTimeCardView(text: "이용 시간", time: 77777)
                        AccTimeCardView(text: "이용 시간", time: 77777, color: Color(hex: "#735BF2"))
                        TabView{
                            ChartView(item: items[0])
                            ChartView(item: items[1])
                        }
                        .tabViewStyle(.page)
                        .padding(.horizontal, 30)
                        .frame(height: 289)
                        PopulationView()
                            .padding(.horizontal, 30)
                    }
                }
            }
        }
        .navigationTitle("알림")

    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
