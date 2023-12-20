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
        VStack(alignment: .leading, spacing: 8) {
            Text("실시간 현황")
                .font(.system(size: 18, weight: .bold))

            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                HStack(alignment: .bottom, spacing: 0) {
                    Text("서울")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.horizontal, 20)
                        .foregroundColor(.black)
                    Spacer()
                    Text("\(hane.clusterPopulation)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.leading, 20)
                    Text("명")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.trailing, 20)
                }
            }
        }
    }
}

#Preview {
    PopulationView()
        .environmentObject(Hane())
}
