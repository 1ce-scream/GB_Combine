//
//  SlotsMachineVM.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 24.06.2022.
//

import SwiftUI
import Combine

final class SlotsMachineVM: ObservableObject {
    @Published var run: Bool = false
    @Published var startGame = false
    @Published var firstSlot: String = "🤖"
    @Published var secondSlot: String = "🤖"
    @Published var thirdSlot: String = "🤖"
    @Published var textTitle = ""
    @Published var buttonText = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    private let arrayEmoji = ["🤪", "😎", "😜", "🥶", "😷", "🤯"]
     
    init() {
        timer
            .receive(on: RunLoop.main)
            .sink { _ in self.random() }
            .store(in: &cancellables)
        
        $run
            .receive(on: RunLoop.main)
            .map {
                guard !$0 && self.startGame else { return "Let's play!" }
                return (
                    self.firstSlot == self.secondSlot
                    && self.firstSlot == self.thirdSlot ? "You won!" : "You lose!"
                )
            }
            .assign(to: \.textTitle, on: self)
            .store(in: &cancellables)
        
        $run
            .receive(on: RunLoop.main)
            .map { $0 == true ? "Catch it!" : "Start" }
            .assign(to: \.buttonText, on: self)
            .store(in: &cancellables)
    }
    
    private func random() {
        guard run else { return }
        firstSlot = arrayEmoji.randomElement() ?? ""
        secondSlot = arrayEmoji.randomElement() ?? ""
        thirdSlot = arrayEmoji.randomElement() ?? ""
    }
}
