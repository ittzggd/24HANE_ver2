//
//  notificationView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/14/23.
//

import SwiftUI

struct notificationView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            VStack() {
                ZStack(alignment: .topLeading){
                    Color.defaultBG.ignoresSafeArea()
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    
                    VStack{
                        HStack{
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }, label: {
                                Image(systemName: "chevron.left")
                                    .imageScale(.large)
                                    .padding()
                            })
                            Text("알림")
                                .font(.system(size: 20, weight: .bold))
                                .padding(.leading, 128)
                                .padding(.trailing, 177)
                        }
                        Text("알림 내역이 비어있습니다.💌 ")
                            .padding()
                        Divider()
                    }
                }
            }
        }
    }
}

struct notificationView_Previews: PreviewProvider {
    static var previews: some View {
        notificationView()
    }
}
