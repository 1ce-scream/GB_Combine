//
//  SkyInfoModel.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 25.06.2022.
//

import Foundation

struct SkyInfoModel: Identifiable {
    typealias Asteroids = (key: String, value: [NearEarthObject])
    
    let id = UUID()
    let apod: APOD
    let neos: Asteroids
}
