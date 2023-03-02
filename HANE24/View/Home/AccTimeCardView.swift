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
    
    @EnvironmentObject var hane: Hane
    
    @State var text: String
    var accTime: Int64
    @State var isColored: Bool = false
    @State var viewColor: Color = Color(.white)
    @State var isFold: Bool = true
    @State var targetTime: Int64 = 3600 * 8
    @State var drawingStroke = false
    var options: Array<Double>
    @State var select: Int
    
    let onSelect:(Int) -> Void
    
    
    let animation = Animation
        .easeOut(duration: 0.8)
        .delay(0.1)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(isFold ? viewColor : .white)
            
            VStack(spacing: 5) {
                Button {
                    withAnimation {
                        isFold.toggle()
                        drawingStroke = false
                    }
                } label: {
                    HStack {
                        Text(text)
                            .font(.system(size: 17 , weight: .bold))
                        Spacer()
                        ZStack{
                            if hane.loading {
                                LoadingAnimation()
                                    .padding(.trailing, 10)
                            } else {
                                HStack(alignment: .bottom, spacing: 0) {
                                    Text("\(accTime / 3600)")
                                        .font(.system(size: 20, weight: .semibold))
                                    Text("시간 ")
                                    Text("\(accTime % 3600 / 60)")
                                        .font(.system(size: 20, weight: .semibold))
                                    Text("분")
                                }
                            }
                        }
                        
                        Image(systemName: "chevron.right")
                            .rotationEffect(isFold ? Angle(degrees: 0) : Angle(degrees: 90))
                            .isHidden(hane.loading)
                    }
                    .foregroundColor(isFold && isColored ? .white : .black)
                    .font(.system(size: 16, weight: .semibold))
                    .padding()
                }
                
                if !isFold {
                    VStack {
                        HStack {
                            Text("목표 시간")
                            Spacer()
                            Menu{
                                Picker(selection: $select) {
                                    ForEach(0..<options.count, id: \.self){ times in
                                        Text("\(Int(options[times])) 시간")
                                    }
                                } label: {}.onChange(of: select) { _ in
                                    onSelect(select)
                                }
                            } label : {
                                Text("\(Int(options[select]))")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("시간")
                                Image(systemName: "chevron.down")
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.gray)
                                    .hidden()
                            }                            
                            
                        }
                        .foregroundColor(isFold && isColored ? .white : .black)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal)
                        
                        ProgressCircle
                            .frame(width: 120, height: 120)
                            .padding(.bottom, 10)
                            .animation(animation, value: drawingStroke)
                            .onAppear{
                                drawingStroke = true
                            }
                    }
                }
            }
            .padding()
        }
        .frame(height: isFold ? 80 : 260, alignment: .top)
    }
    
    var ProgressCircle: some View {
                                
        ZStack{

            Text("\(Int(Double(accTime) / Double(options[select] * 3600) * 100))%")
                .font(.system(size: 32, weight: .medium, design: .default))
                .foregroundColor(.black)
            Circle()
                .stroke( AngularGradient(gradient: Gradient(colors: [ .gradientBlue.opacity(0.1), .gradientWhtie.opacity(0.1), .gradientPurple.opacity(0.1), .gradientPurple.opacity(0.1),.gradientWhtie.opacity(0.1), .gradientBlue.opacity(0.1)]), center: .center, startAngle: .zero, endAngle: .degrees(360)), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .overlay{
                    Circle()
                        .trim(from:0, to: drawingStroke ? (Double(accTime) / Double(options[select] * 3600)) : 0)
                        .stroke( AngularGradient(gradient: Gradient(colors: [ .gradientBlue.opacity(0.35), .gradientWhtie, .gradientPurple, .gradientPurple ,.gradientWhtie, .gradientBlue.opacity(0.35)]), center: .center, startAngle: .zero, endAngle: .degrees(360)), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                }
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

//struct AccTimeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccTimeCardView(text: "이용 시간", accTime: 3600 * 4 + 120)
//        AccTimeCardView(text: "이용 시간", accTime: 77777, isColored: true, viewColor: Color(hex: "#735BF2"))
//    }
//}
