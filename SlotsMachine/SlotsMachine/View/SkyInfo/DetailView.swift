//
//  DetailView.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 25.06.2022.
//

import Foundation
import SwiftUI

struct DetailView: View {
    typealias Asteroids = (key: String, value: [NearEarthObject])
    
    @State var detailData: Asteroids
    @State var date: String
    
    var body: some View {
        List(detailData.value) { info in
            VStack(alignment: .leading) {
                Text("Name: \(info.name)")
                    .font(.title3)
                    .padding([.top,.bottom])
                Text("Is object potentially hazardous: \(info.isPotentiallyHazardousAsteroid.description)")
                Text("Is object sentry: \(info.isSentryObject.description)")
                    .padding(.bottom, 10)
                Link("More info from  NASA", destination: URL(string: "\(info.nasaJplURL)")!)
            }
        }
        .navigationTitle("\(date)")
    }
}
