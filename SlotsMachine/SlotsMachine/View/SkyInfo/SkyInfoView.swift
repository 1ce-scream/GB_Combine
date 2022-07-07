//
//  SkyInfoView.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 24.06.2022.
//

import SwiftUI

struct SkyInfoView: View {
    @ObservedObject private var viewModel: SkyInfoVM
    @State private var startDate = ""
    @State private var endDate = ""
    
    private let cornerRadius: CGFloat = 15
    
    init(viewModel: SkyInfoVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                
                // TODO: сопоставить положение последнего элемента с размерами списка
                // https://swiftwithmajid.com/2020/01/15/the-magic-of-view-preferences-in-swiftui/
                List(viewModel.skyInfoModels) { info in
                    VStack {
                        NavigationLink(destination: DetailView(detailData: info.neos,
                                                               date: info.apod.date)) {
                            VStack {
                                Text("Date: \(info.apod.date)")
                                    .font(.body)
                                Text("Tap to show Asteroinds info at this day")
                                    .font(.subheadline)
                            }
                        }
                        SkyInfoCell(skyInfo: info)
                    }
                }
                .alert(item: $viewModel.error) { error in
                    Alert(title: Text("Error"), message: Text(error.errorDescription ?? ""))
                }
//                .onReceive(viewModel.timer, perform: { _ in
//                    viewModel.fetchSkyInfo(startDate: startDate, endDate: endDate)
//                })
                .navigationTitle("\(Tabs.SkyInfo.rawValue)")
                
                VStack(alignment: .center, spacing: 0) {
                    Text("Date format YYYY-MM-DD")
                        .foregroundColor(.white)
                        .font(.title3)
                    HStack(alignment: .center, spacing: 8) {
                        Spacer()
                        TextField("Start date", text: $startDate)
                            .textFieldStyle(.roundedBorder)
                            .cornerRadius(cornerRadius)
                        TextField("End date", text: $endDate)
                            .textFieldStyle(.roundedBorder)
                            .cornerRadius(cornerRadius)
                        Spacer()
                    }
                    .padding(.top, 10)

                    Button("Get sky info") {
                        print("tapped")
                        guard !startDate.isEmpty && !endDate.isEmpty else {return}
                        self.viewModel.fetchSkyInfo(startDate: startDate,
                                                    endDate: endDate)
                    }
                    .buttonStyle(.bordered)
                    .background(.green)
                    .foregroundColor(.white)
                    .cornerRadius(cornerRadius)
                    .padding([.top, .bottom], 10)
                }
                .background(.blue.opacity(0.8))
                .cornerRadius(cornerRadius)
                .frame(width: geometry.size.width * 0.95)
            }
        }
    }
}

struct SkyInfo_Previews: PreviewProvider {
    static var previews: some View {
        SkyInfoView(viewModel: SkyInfoVM() )
            .previewDisplayName("SkyInfo")
            .previewDevice("iPhone 13 mini")
    }
}
