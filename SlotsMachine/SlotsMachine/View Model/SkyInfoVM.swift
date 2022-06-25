//
//  SkyInfoVM.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 24.06.2022.
//

import SwiftUI
import Combine

final class SkyInfoVM: ObservableObject {    
    typealias asteroids = (key: String, value: [NearEarthObject])

    @Published var skyInfoModels: [SkyInfoModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    private lazy var networkService = NetworkService()
    
    func fetchSkyInfo(startDate: String, endDate: String) {
        skyInfoModels.removeAll()
        networkService.fetchSkyInfo(startDate: startDate, endDate: endDate)
//            .debounce(for: .seconds(2.0), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                    switch value {
                    case .failure:
                        self.skyInfoModels = []
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] apod, asteroid in
                    guard let self = self else { return }
                    self.skyInfoModels.append(SkyInfoModel(apod: apod, neos: asteroid))
                }
            )
            .store(in: &cancellables)
    }
}
