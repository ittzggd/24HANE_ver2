//
//  AccTimeCardView.swift
//  HANE24
//
//  Created by Yunki on 2023/02/14.
//

import SwiftUI
/// text: String - 뷰 왼쪽에 나타날 문자열
/// time: Int64 - 시간 (초 / sec)
/// isColored: Bool - 뷰 색상 여부
/// viewColor: Color - 뷰 내부 색상
struct AccTimeCardView: View {
    @State var text: String
    @State var accTime: Int64
    @State var isColored: Bool = false
    @State var viewColor: Color = Color(.white)
    @State var isFold: Bool = true
    @State var targetTime: Int64 = 3600 * 8
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(isFold ? viewColor : .white)
            
            VStack(spacing: 18) {
                HStack {
                    Text(text)
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Text("\(accTime / 3600)시간 \(accTime % 3600 / 60)분")
                    Image(systemName: "chevron.right")
                        .rotationEffect(isFold ? Angle(degrees: 0) : Angle(degrees: 90))
                }
                .foregroundColor(isFold && isColored ? .white : .black)
                .font(.system(size: 16, weight: .semibold))
                .padding()
                .onTapGesture {
//                    withAnimation {
                        isFold.toggle()
//                    }
                }
                
                if !isFold {
                    VStack {
                        HStack {
                            Text("목표 시간")
                            Spacer()
                            Text("\(targetTime / 3600)시간")
                            Image(systemName: "chevron.right")
                                .foregroundColor(isFold ? viewColor : .white)
                        }
                        .foregroundColor(isFold && isColored ? .white : .black)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal)
                        
                        ProgressCircle
                            .frame(width: 120, height: 120)
                            .padding(.bottom, 10)
                    }
                }
            }
            .padding()
        }
        .frame(height: isFold ? 80 : 260, alignment: .top)
        .padding(.horizontal, 30)
    }
    
//    let progress: Double = Double(accTime) / Double(targetTime)
    var ProgressCircle: some View {
                                
        ZStack{
            Text("\(Int(Double(accTime) / Double(targetTime) * 100))%")
                .font(.system(size: 30, weight: .medium, design: .default))
                .foregroundColor(.black)
            Circle()
                .stroke(Color(UIColor.systemGray3).opacity(0.5), lineWidth: 16)
            Circle()
                .trim(from:0, to: (Double(accTime) / Double(targetTime)))
                .stroke(LinearGradient(gradient: Gradient(colors: [.gradientBlue, .gradientPurple]), startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(270))
        }
    }
}

extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}

struct AccTimeCardView_Previews: PreviewProvider {
    static var previews: some View {
        AccTimeCardView(text: "이용 시간", accTime: 3600 * 4 + 120)
        AccTimeCardView(text: "이용 시간", accTime: 77777, isColored: true, viewColor: Color(hex: "#735BF2"))
    }
}
