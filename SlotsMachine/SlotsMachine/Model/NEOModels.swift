//
//  NEOModels.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 24.06.2022.
//

import Foundation

// MARK: - Near Earth Objects models
struct NeoResponse: Codable {
    let elementCount: Int
    let nearEarthObjects: [String: [NearEarthObject]]
    
    enum CodingKeys: String, CodingKey {
        case elementCount = "element_count"
        case nearEarthObjects = "near_earth_objects"
    }
}

extension NeoResponse: CustomStringConvertible {
    var description: String {
        return "\n Astronomy objects count: \(elementCount) \n Objects: \n \(nearEarthObjects)"
    }
}

struct NearEarthObject: Codable, Identifiable {
    var id = UUID()
    
    let name: String
    let nasaJplURL: String
    let isPotentiallyHazardousAsteroid: Bool
    let isSentryObject: Bool
    
    enum CodingKeys: String, CodingKey {
        case name
        case nasaJplURL = "nasa_jpl_url"
        case isPotentiallyHazardousAsteroid = "is_potentially_hazardous_asteroid"
        case isSentryObject = "is_sentry_object"
    }
}

extension NearEarthObject: CustomStringConvertible {
    var description: String {
        "\n Name: \(name), isHazardous: \(isPotentiallyHazardousAsteroid), isSentry: \(isSentryObject), \n NASA info \(nasaJplURL) \n"
    }
}
