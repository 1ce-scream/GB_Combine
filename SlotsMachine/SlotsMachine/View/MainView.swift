//
//  MainView.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 24.06.2022.
//

import SwiftUI

enum Tabs: String {
    case SkyInfo = "Sky Info"
    case SlotsMachine = "Slots Machine"
}

enum Icon: String {
    case SkyInfo = "moon.stars.fill"
    case SlotsMachine = "gamecontroller.fill"
}

struct MainView: View {
    private let NASAViewModel = NASAVM()
    private let SlotsMachineViewModel = SlotsMachineVM()
    
    @State private var selectedTab: Tabs = .SkyInfo
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                SkyInfo(viewModel: NASAViewModel)
            }
            .tabItem {
                Label(Tabs.SkyInfo.rawValue,
                      systemImage: Icon.SkyInfo.rawValue)
            }
            .tag(Tabs.SkyInfo)
            
            NavigationView {
                SlotsMachine()
            }
            .tabItem {
                Label(Tabs.SlotsMachine.rawValue,
                      systemImage: Icon.SlotsMachine.rawValue)
            }
            .tag(Tabs.SlotsMachine)
        }
        .navigationTitle(selectedTab.rawValue)
        .navigationBarBackButtonHidden(true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .previewDisplayName("MainView")
            .previewDevice("iPhone 13 mini")
    }
}
