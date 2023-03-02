//
//  CardProgressView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/28/23.
//

import SwiftUI

struct CardProgressView: View {
    var item: progressItem
    
    var body: some View {

        HStack(spacing: 15) {
            ZStack{
                Circle()
                    .stroke(lineWidth: 4)
                    .overlay( item.isProcessing ? Circle() : nil)
                    .foregroundColor(item.isProcessing ? .gradientPurple : Color(hex: "EAEAEA"))
                    .frame(width: 50, height: 50)
                Text(item.id)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(item.isProcessing ?  Color(hex: "EAEAEA") : .iconColor)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .bold))
                Text(item.statement)
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .regular))
            }
        }
        .padding()
    }

}

struct CardProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CardProgressView(item:  progressItem(id: "신청", title: "신청 후 업체에 입금해주세요", statement: "업체에서 입금 확인 후 제작이 진행됩니다.", isProcessing: true))
    }
}
