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
    case TestView = "Test View"
}

enum Icon: String {
    case SkyInfo = "moon.stars.fill"
    case SlotsMachine = "gamecontroller.fill"
    case TestView = "infinity"
}

struct MainView: View {
    private let SkyInfoViewModel = SkyInfoVM()
    private let SlotsMachineViewModel = SlotsMachineVM()
    
    @State private var selectedTab: Tabs = .SkyInfo
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                SkyInfoView(viewModel: SkyInfoViewModel)
            }
            .tabItem {
                Label(Tabs.SkyInfo.rawValue,
                      systemImage: Icon.SkyInfo.rawValue)
            }
            .tag(Tabs.SkyInfo)
            
            NavigationView {
                SlotsMachine(viewModel: SlotsMachineViewModel)
            }
            .tabItem {
                Label(Tabs.SlotsMachine.rawValue,
                      systemImage: Icon.SlotsMachine.rawValue)
            }
            .tag(Tabs.SlotsMachine)
            
            NavigationView {
                TestPreferenceKeyView()
//                CheckScrollViewSize()
            }
            .tabItem {
                Label(Tabs.TestView.rawValue,
                      systemImage: Icon.TestView.rawValue)
            }
            .tag(Tabs.TestView)
        }
        .navigationTitle(selectedTab.rawValue)
        .navigationBarBackButtonHidden(true)
        // fix constraints errors
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .previewDisplayName("MainView")
            .previewDevice("iPhone 13 mini")
    }
}
