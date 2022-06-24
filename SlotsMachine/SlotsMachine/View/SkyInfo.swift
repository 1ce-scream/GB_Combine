//
//  SkyInfo.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 24.06.2022.
//

import SwiftUI

struct SkyInfo: View {
    @ObservedObject private var viewModel: NASAVM
    @State private var startDate = ""
    @State private var endDate = ""
    
    init(viewModel: NASAVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                
                List(viewModel.APODs) { apods in
                    SkyInfoCell(apod: apods)
                }
                .navigationTitle("\(Tabs.SkyInfo.rawValue)")
                .onAppear{
//                    viewModel.fetchSkyInfo()
                    UITableView.appearance().backgroundColor = .clear
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Text("Date format YYYY-MM-DD")
                        .foregroundColor(.white)
                        .font(.title3)
                    HStack(alignment: .center, spacing: 8) {
                        Spacer()
                        TextField("Start date", text: $startDate)
                            .textFieldStyle(.roundedBorder)
                            .cornerRadius(15)
                        TextField("End date", text: $endDate)
                            .textFieldStyle(.roundedBorder)
                            .cornerRadius(15)
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    Button("Get sky info") {
                        print("tapped")
                        self.viewModel.fetchSkyInfo(startDate: startDate,
                                                    endDate: endDate)
                    }
                    .buttonStyle(.bordered)
                    .background(.green)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding()
                }
                .background(.blue.opacity(0.8))
                .cornerRadius(20)
                .padding(.bottom, 10)
                .frame(width: geometry.size.width - 10)
            }
        }
    }
}

struct SkyInfo_Previews: PreviewProvider {
    static var previews: some View {
        SkyInfo(viewModel: NASAVM() )
            .previewDisplayName("SkyInfo")
            .previewDevice("iPhone 13 mini")
    }
}
