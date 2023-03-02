//
//  ReissuanceView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/15/23.
//

import SwiftUI

struct progressItem: Identifiable{
    var id: String
    var title: String
    var statement: String
    var isProcessing: Bool
}

//
//var processItems: [progressItem] = [
//    progressItem(id: "신청", title: "신청 후 업체에 입금해주세요", statement: "업체에서 입금 확인 후 제작이 진행됩니다.", isProcessing: false),
//    progressItem(id: "제작", title: "제작 기간은 약 2주간 소요됩니다", statement: "출입카드 재발급 신청 후 업체에서 입금 확인 후 제작이 진행됩니다.", isProcessing: false),
//    progressItem(id: "완료", title: "카드를 수령해주세요", statement: "재발급 카드는 데스크에서 수령 가능합니다", isProcessing: false)
//]

struct alertItem: Identifiable{
    var id: String
    var title1: String
    var title2: String
    var statement: String
    var buttonTitle: String
}

var items: [alertItem] = [
    alertItem(id: "신청", title1: "카드 재발급을", title2: "신청하시겠습니까?", statement: "신청 후 취소가 불가능합니다.", buttonTitle: "네, 신청하겠습니다"),
    alertItem(id: "수령", title1: "저는 카드를 받았음을", title2: "확인했습니다.", statement: "실물 카드를 받은 후 눌러주세요.", buttonTitle: "네, 확인했습니다")
    
]



struct ReissuanceView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var hane: Hane
    @State var showAlert = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Theme.BackgoundColor(forScheme: colorScheme)
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
            
            VStack {
                HStack{
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Theme.ToolBarIconColor(forScheme: colorScheme))
                            .imageScale(.large)
                            .padding()
                    })
                    Text("카드 재발급 신청")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.leading, 70)
                        .padding(.trailing, 120)
                }
                .padding(.bottom, 15)
                VStack(spacing: 15) {
                    HStack{
                        Text("재발급 신청 방법")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                    }
                    Button {
                        if let url = URL(string: "https://www.notion.so") {
                            openURL(url)}
                        } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(colorScheme == .dark ? .white : .chartDetailBG)
                                .frame(height: 45)
                            Text("자세히보기")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .chartDetailBG : .LightDefaultBG)
                        }
                    }
                    .padding(.bottom, 20)
                    HStack{
                        Text("재발급 신청 현황")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white)
                            .frame(height: 300)
                        VStack(alignment: .leading){
                            CardProgressView(item: progressItem(id: "신청", title: "신청 후 업체에 입금해주세요", statement: "업체에서 입금 확인 후 제작이 진행됩니다.", isProcessing: (hane.reissueState == .apply)))
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color(hex: "D9D9D9"))
                                .padding(.horizontal, 30)
                            CardProgressView(item:  progressItem(id: "제작", title: "제작 기간은 약 2주간 소요됩니다", statement: "출입카드 재발급 신청 후 업체에서 입금 확인 후 제작이 진행됩니다.", isProcessing: (hane.reissueState == .inProgress)))
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color(hex: "D9D9D9"))
                                .padding(.horizontal, 30)
                            CardProgressView(item: progressItem(id: "완료", title: "카드를 수령해주세요", statement: "재발급 카드는 데스크에서 수령 가능합니다", isProcessing: (hane.reissueState == .pickUpRequested)))
                        }
                    }
                    Spacer()
                    if hane.reissueState != .pickUpRequested {
                        reissueButton
                    } else {
                        receiveButton
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            if showAlert {
                AlertView(showAlert: $showAlert, item: (hane.reissueState == .pickUpRequested) ? items[1] : items[0])
            }
        }
    }
    
    var reissueButton: some View {
        Button (action :{
            showAlert.toggle()
        },
        label: {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor((hane.reissueState == .none || hane.reissueState == .done) ? .gradientPurple : .textGrayMoreView)
                    .frame(height: 45)
                Text("카드 신청하기")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        })
        .disabled((hane.reissueState != .none && hane.reissueState != .done))
    }
    
    var receiveButton: some View {
        Button (action :{
            showAlert.toggle()
        },
        label: {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor((hane.reissueState == .pickUpRequested) ? .gradientPurple : .iconColor)
                    .frame(height: 45)
                Text("데스크 카드 수령 완료")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        })
    }

}

struct ReissuanceView_Previews: PreviewProvider {
    static var previews: some View {
        ReissuanceView()
            .environmentObject(Hane())
    }
}
