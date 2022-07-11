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
//            KFImage(URL(string: self.skyInfo.apod.hdurl ?? self.skyInfo.apod.url))
//                .resizable()
//                .aspectRatio(1, contentMode: .fill)
//                .padding()
            
            AsyncImage(url: URL(string: self.skyInfo.apod.hdurl ?? self.skyInfo.apod.url),
                       transaction: Transaction(animation: .easeInOut)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .transition(.scale(scale: 0.1, anchor: .center))
                case .failure:
                    Image(systemName: "wifi.slash")
                        .frame(width: 44, height: 44, alignment: .center)
                @unknown default:
                    EmptyView()
                }
            }
            
            Text("\(self.skyInfo.apod.explanation)")
                .font(.caption)
        }
        .listRowSeparatorTint(Color.blue)
    }
}
