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
    
    let skyInfo: SkyInfoModel
    
// MARK: - Body
    
    var body: some View {
        VStack {
            Text("Date: \(self.skyInfo.apod.date)")
                .font(.body)
            
            Text("Tap to show Asteroinds info at this day")
                .font(.subheadline)
            
            KFImage(URL(string:self.skyInfo.apod.hdurl ?? self.skyInfo.apod.url))
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .padding()
            
            Text("\(self.skyInfo.apod.explanation)")
                .font(.caption)
            
            Spacer()
        }
        .listRowSeparatorTint(Color.blue)
    }
}
