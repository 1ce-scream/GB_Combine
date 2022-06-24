//
//  SlotsMachineVM.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 24.06.2022.
//

import SwiftUI
import Combine

final class SlotsMachineVM: ObservableObject {
    let startDate = "2022-06-17"
    let endDate = "2022-06-19"
    
    private var cancellables = Set<AnyCancellable>()
    private lazy var networkService = NetworkService()
}
