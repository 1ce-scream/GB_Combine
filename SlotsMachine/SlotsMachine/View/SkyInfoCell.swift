//
//  SkyInfoCell.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 24.06.2022.
//

import SwiftUI
import Kingfisher

struct SkyInfoCell: View {

// MARK: - Properties
    
    let apod: APOD
//    let neo: NearEarthObject
    
// MARK: - Body
    
    var body: some View {
        VStack {
                KFImage(URL(string:self.apod.hdurl ?? self.apod.url))
                .resizable()
                .frame(width: 200, height: 200)
                
                Text("\(self.apod.explanation)")
                .font(.caption)
                
                Spacer()
            
//            Text("\(self.community.description!)")
//                .font(.subheadline)
//                .fixedSize(horizontal: false, vertical: true)
        }
        .listRowSeparatorTint(Color.blue)
    }
}
