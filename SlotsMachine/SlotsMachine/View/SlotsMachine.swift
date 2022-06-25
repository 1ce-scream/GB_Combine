//
//  SlotsMachine.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 24.06.2022.
//

import SwiftUI

struct SlotsMachine: View {
    @ObservedObject private var viewModel: SlotsMachineVM
    
    init(viewModel: SlotsMachineVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea(.all, edges: .top)
            VStack {
                Text(viewModel.textTitle)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack {
                    Text(viewModel.firstSlot)
                    Text(viewModel.secondSlot)
                    Text(viewModel.thirdSlot)
                    
                }
                .font(.system(size: 80))
                
                Spacer()
                
                Button(viewModel.buttonText) {
                    print("tapped")
                    viewModel.run.toggle()
                    viewModel.startGame = true
                }
                .foregroundColor(.white)
                .font(.system(size: 60))
                .padding(.bottom, 10)
            }
        }
    }
}

struct SlotsMachine_Previews: PreviewProvider {
    static var previews: some View {
        SlotsMachine(viewModel: SlotsMachineVM())
            .previewDisplayName("SlotsMachine")
            .previewDevice("iPhone 13 mini")
    }
}
