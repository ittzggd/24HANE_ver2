//
//  ErrorView.swift
//  HANE24
//
//  Created by Katherine JANG on 3/2/23.
//

import SwiftUI

struct ErrorView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack{
            Theme.BackgoundColor(forScheme: colorScheme)
                .ignoresSafeArea(.all)
            VStack{
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()
                Text("요청하신 동작을")
                    .font(.system(size: 20, weight: .bold))
                Text("처리할 수 없습니다.")
                    .font(.system(size: 20, weight: .bold))
                Text("실행중에 오류가 발생했습니다.")
                    .padding(.top)
                    .foregroundColor(Color.iconColor)
                Text("다시 시도해주세요.")
                    .foregroundColor(Color.iconColor)
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
