//
//  AccTimeCardView.swift
//  HANE24
//
//  Created by Yunki on 2023/02/14.
//

import SwiftUI

struct AccTimeCardView: View {
    @State var text: String
    @State var time: Int64 = 0
    @State var color: Color = Color(.white)
//    @State var textcolor: Color = color == Color(.white) ? Color(.black) : Color(.white)
    @State var isFold: Bool = true
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(color)
            VStack(spacing: 10) {
                HStack(){
                    Text(text)
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    HStack(alignment: .center, spacing: 1){
                        Text("\(time / 3600)")
                            .font(.system(size: 20, weight: .semibold))
                        Text("시간")
                            .font(.system(size: 16, weight: .semibold))
                        Text("\(time % 3600 / 60)")
                            .font(.system(size: 20, weight: .semibold))
                        Text("분")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Button {
                        isFold.toggle()
                    } label: {
                        Image(systemName: "chevron.right")
                            .rotationEffect(isFold ? Angle(degrees: 0) : Angle(degrees: 90))
                    }
                }
                .foregroundColor(.black)
               // .fontWeight(.semibold)
                .padding()
                if !isFold {
                    VStack {
                        HStack {
                            Text("목표 시간")
                            Spacer()
                            Text("\(time / 3600)시간 \(time % 3600 / 60)분")
                            Image(systemName: "chevron.right")
                                .foregroundColor(color)
                        }
                        .foregroundColor(.black)
                        //.fontWeight(.semibold)
                        .padding(.horizontal)
                        ProgressCircle
                            .frame(width: 120, height: 120)
                    }
                }
            }
            .padding()
        }
        //.padding()
        .frame(maxHeight: isFold ? 80 : 243)
        .padding(.horizontal, 30)
    }
    
    let progress: Double = 0.7
    var ProgressCircle: some View {
        ZStack{
            if progress >= 1 {
                Text("100%")
                    .font(.system(size: 30, weight: .medium, design: .default))
                    .foregroundColor(.black)
            } else {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 30, weight: .medium, design: .default))
                    .foregroundColor(.black)
            }
            Circle()
                .stroke(
                    Color(UIColor.systemGray3).opacity(0.5),
                    lineWidth: 13
                )
            Circle()
                .trim(from:0, to: (progress))
                .stroke(.blue, style: StrokeStyle(lineWidth: 13, lineCap: .round))
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
//        AccTimeCardView(text: "이용 시간", time: 77777)
        AccTimeCardView(text: "이용 시간", time: 77777, color: Color(hex: "#735BF2"))
    }
}
