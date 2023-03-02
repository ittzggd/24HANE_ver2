//
//  LoadingView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/21/23.
//

import SwiftUI

struct LoadingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Theme.CalendarBackgoundColor(forScheme: colorScheme)
                .edgesIgnoringSafeArea(.all)
//            if colorScheme == .light {
                Image("LaunchScreen")
                    .ignoresSafeArea(.all)
//            } else {
//                Image("LaunchScreen_dark")
//                    .ignoresSafeArea(.all)
//            }
        }
    }
}

struct LoadingAnimation: View {
    @State private var animationTrigger: Bool = true
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .frame(width: 6, height: 6)
                .foregroundColor(animationTrigger ? Color(hex: "#D9D9D9") : Color(hex: "#735BF2"))
                .animation(changeColor, value: animationTrigger)
            Circle()
                .frame(width: 6, height: 6)
                .foregroundColor(animationTrigger ? Color(hex: "#D9D9D9") : Color(hex: "#735BF2"))
                .animation(changeColor.delay(0.4), value: animationTrigger)
            Circle()
                .frame(width: 6, height: 6)
                .foregroundColor(animationTrigger ? Color(hex: "#D9D9D9") : Color(hex: "#735BF2"))
                .animation(changeColor.delay(0.8), value: animationTrigger)
        }
        .frame( height: 24)
        .onAppear {
            animationTrigger.toggle()
        }
    }
    
    var changeColor: Animation {
        Animation
            .easeInOut(duration: 1.2)
            .repeatForever()
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
//        LoadingAnimation()
    }
}
