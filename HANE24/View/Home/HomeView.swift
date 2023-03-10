//
//  HomeView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/13/23.
//

import SwiftUI

func getWeeklyPeriod() -> [String]{
    var weeklyPeriod:[String] = []
    var date = Date()
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "M.dd(EEE)"
    for _ in 0..<6 {
        let startDay = formatter.string(from: date.startOfWeek!)
        let endDay = formatter.string(from: date.endOfWeek!)
        let period = startDay + " - " + endDay
        weeklyPeriod.append(period)
        date = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: date)!
    }
    return weeklyPeriod
}

func getMonthlyPeriod() -> [String] {
    var monthlyPeriod:[String] = []
    var date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY.M"
    for _ in 0..<6 {
        let period = formatter.string(from: date)
        monthlyPeriod.append(period)
        date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
    }
    return monthlyPeriod
}

var dailyOptions: Array<Double> = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
var monthlyOptions: Array<Double> = [80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300, 320, 340, 360, 380, 400, 420]

struct PullToRefresh: View {
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName))).midY > 50 {
                Spacer()
                    .onAppear{
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).midY < 10) {
                Spacer()
                    .onAppear{
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack{
                Spacer()
                if needRefresh {
                    ProgressView()
                }
                Spacer()
            }
        } .padding(.top, -50)
    }
}


struct HomeView: View {
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.gradientPurple)
          UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.2)
    }
    @State var test: Bool = true
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var hane: Hane
    @AppStorage("DailySelectionOption") private var dailySelectionOption =  UserDefaults.standard.integer(forKey: "DailySelectionOption")
    @AppStorage("MonthlySelectionOption") private var monthlySelectionOption =  UserDefaults.standard.integer(forKey: "MonthlySelectionOption")

    var body: some View {
        NavigationView{
           ZStack{
               if hane.isInCluster {
                   Image("Background")
                        .resizable()
                        .edgesIgnoringSafeArea(.top)
                        .opacity(0.7)
               } else {
                   Theme.BackgoundColor(forScheme: colorScheme)
                       .edgesIgnoringSafeArea(colorScheme == .dark ? .all : .top)
               }
               VStack(alignment: .center, spacing: 20) {
                    HStack(alignment: .center) {
                        if hane.profileImage != "" {
                            AsyncImage(url: URL(string: hane.profileImage)) { image in
                                image
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .padding(.trailing, 3)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .padding(.trailing, 3)
                                    .foregroundColor(.iconColor)
                            }
                        } else {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .padding(.trailing, 3)
                                .foregroundColor(.iconColor)
                        }
                        
                        Text(hane.loginID)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(!hane.isInCluster && colorScheme == .light ? .black : .white)
                        
                        if hane.isInCluster {
                            Circle()
                                .foregroundColor(.green)
                                .frame(width:8, height: 8)
                                .padding(.bottom, 10)
                                .padding(.leading, 0)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: notificationView()) {
                            Image("notification")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(test ? .iconColor : .red)
                        }
                        .hidden()
                        .navigationBarHidden(true)
                        .frame(width: 24, height: 24)
                    }
                    .padding(.top, 20)
                    .frame(height: 30)
                    .padding(.horizontal, 30)
                   
                    ScrollView{
                        PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                            /// [FixMe]
                            Task{
                                try await hane.refresh(date: Date())
                            }
                        }
                        
                        VStack(spacing: 22.5){
                            AccTimeCardView(text: "?????? ??????", accTime: hane.dailyAccumulationTime, options: dailyOptions, select: dailySelectionOption) { selection in
                                UserDefaults.standard.setValue(selection, forKey: "DailySelectionOption")
                            }
                                .padding(.horizontal, 30)
                            
                            AccTimeCardView(text: "??? ?????? ??????", accTime: hane.monthlyAccumulationTime, isColored: true, viewColor: Color(hex: "#735BF2"), options: monthlyOptions, select: monthlySelectionOption) {selection in
                                UserDefaults.standard.setValue(selection, forKey: "MonthlySelectionOption")
                            }
                                .padding(.horizontal, 30)

                            TabView{
                                ChartView(item: ChartItem(id: "???", title: "?????? ?????? ?????????", period: getWeeklyPeriod(), data: hane.sixWeekAccumulationTime))
                                    .padding(.horizontal, 10)
                                ChartView(item: ChartItem(id: "??????", title: "?????? ?????? ?????????", period: getMonthlyPeriod(), data: hane.sixMonthAccumulationTime))
                                    .padding(.horizontal, 10)
                            }
                            .padding(.horizontal, 20)
                            .tabViewStyle(.page)
                            .frame(height: 289)
                            
                            PopulationView()
                                .padding(.horizontal, 30)
                        }
                        .padding(.bottom, 30)
                        .padding(.top, 10)
                    } .coordinateSpace(name: "pullToRefresh")
                }
            }
        }
    
        .navigationTitle("??????")

    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(Hane())
    }
}
