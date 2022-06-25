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
//    @State var date: String
//    @State var detailData: [NearEarthObject]
   
    
    var body: some View {
//        Text("\(date)")
        List(detailData.value) { info in
            VStack(alignment: .leading) {
                Text("Object name: \n \(info.name)")
                    .font(.title2)
                Text("Is object potentially hazardous: \(info.isPotentiallyHazardousAsteroid.description)")
                Text("Is object sentry: \(info.isSentryObject.description)")
                Text("More info at: \n \(info.nasaJplURL)")
            }
        }
    }
}
