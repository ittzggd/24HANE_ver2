//
//  PopulationView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/14/23.
//

import SwiftUI

struct PopulationView: View {
    @EnvironmentObject var hane: Hane
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack{
                Text("  실시간 현황")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
            }
            HStack(spacing: 25) {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.white)
                        .frame(width: 155, height: 80)
                    HStack{
                        Text("개포")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.trailing, 20)
                            .foregroundColor(.black)
                        Text("\(hane.clusterPopulation.gaepo)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.leading, 20)
                        Text("명")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.white)
                        .frame(width: 155, height: 80)
                    HStack{
                        Text("서초")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.trailing, 20)
                            .foregroundColor(.black)
                        Text("\(hane.clusterPopulation.seocho)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.leading, 20)
                        Text("명")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)

                    }
                }
            }
        }
    }
}

struct PopulationView_Previews: PreviewProvider {
    static var previews: some View {
        PopulationView()
            .environmentObject(Hane())
    }
}
