//
//  MoreView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/15/23.
//

import SwiftUI
import WebKit

var listItems: [MoreItem] = [
    MoreItem(id: UUID(), title: "지원금 지침 안내", url: "https://spot-tomato-468.notion.site/2022-42-SEOUL-bf0513c7197f4f71b4be968b8a2cd75a", image: "book"),
    MoreItem(id: UUID(), title: "출입기록 문의", url: "https://docs.google.com/forms/d/e/1FAIpQLSc_-3n_YwQsR1ZNm5DEChDTABQtw884CuI5laekfDemMmjxow/viewform?usp=send_form", image: "chat"),
    MoreItem(id: UUID(), title: "이용가이드", url: "https://www.notion.so", image: "info"),
    MoreItem(id: UUID(), title: "앱 피드백", url: "https://docs.google.com/forms/d/1Lqs2cOwPdPa-9crMjhATesKpslDLC5XqJ92by_Qk-Qc", image: "user")
    
]

struct MoreView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var hane: Hane
    
    var body: some View {
        NavigationView{
            ZStack(alignment: .topLeading) {
                Theme.BackgoundColor(forScheme: colorScheme)
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 36) {
                    Text("더보기")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top)
                    NavigationLink(destination: ReissuanceView()) {
                        HStack(spacing: 10) {
                            Image("card")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.iconColor)
                            Text("카드 재발급 신청")
                                .foregroundColor(Theme.TextGrayColor(forScheme: colorScheme))
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .navigationBarHidden(true)
                    ForEach(listItems) { item in
                        HStack(spacing: 10) {
                            Image(item.image)
                                .resizable()
                                .frame(width: 24.0, height: 24.0)
                                .foregroundColor(.iconColor)
                                .imageScale(.large)
                            Button {
                                if let url = URL(string: item.url) {
                                    openURL(url)
                                }
                            } label: {
                                Text(item.title)
                                    .foregroundColor(Theme.TextGrayColor(forScheme: colorScheme))
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                    }
                    Button {
                        hane.SignOut()
                    } label: {
                        HStack(spacing: 10) {
                            Image("logout")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.iconColor)
                            Text("로그아웃")
                                .foregroundColor(Theme.TextGrayColor(forScheme: colorScheme))
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    VStack(alignment: .center){
                        Divider()
                        Text("🅒 2023. 24HANE. all rights reserved.")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(Color(hex: "9B9797"))
                    }
                }
                .padding(.horizontal, 30)
            }
        }
        
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
            .environmentObject(Hane())
    }
}
