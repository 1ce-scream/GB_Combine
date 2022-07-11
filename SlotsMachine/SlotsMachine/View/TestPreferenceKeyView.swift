//
//  TestPreferenceKeyView.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 11.07.2022.
//

import SwiftUI

// MARK: - Prefernce key
struct CellOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // height of all visible cells
        value += nextValue()
        
        // height of one cell (in this case. In general depends on transfering value)
        // may be used in case of geomentry.frame(in: .global).minY
//        value = nextValue()
    }
}

// MARK: - View
struct TestPreferenceKeyView: View {
    
    @State var fakeData = FakeData.data
    @State var listOffset: CGFloat = 0
    @State var isHidden: Bool = false
    
    @State var screenHeight: CGFloat = 0
    @State var coefficient: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                List(fakeData) { data in
                    Cell(cellData: data)
                        .modifier(CellPreferenceModifier())
                }
                .overlay(
                    Text("Cells \(listOffset)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                )
                .onPreferenceChange(CellOffsetPreferenceKey.self) { value in
                    listOffset = value
                    
                    // Screen fill factor
                    coefficient = value / geo.size.height
                    
                    if coefficient < 1 && isHidden == true {
                        isHidden.toggle()
                    }
                }
                VStack {
                    Text("Screen \(geo.size.height)")
                    Text("Coef \(coefficient)")
                    
                    Button("TapMe!") {
                        isHidden.toggle()
                    }
                    .buttonStyle(.bordered)
                    .background(.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .opacity(isHidden ? 0 : 1)
                }
            }
        }
    }
}

struct Cell: View {
    let cellData: SomeModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(cellData.color)
                .frame(width: 200, height: 200)
            Text(cellData.text)
        }
    }
}

// MARK: - Modifiers
struct CellPreferenceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geomentry in
                    Color.clear.preference(key: CellOffsetPreferenceKey.self,
                                           value: geomentry.size.height)
                    
                    // distance from the bottom/top of the cell
//                    geomentry.frame(in: .global).minY
                    // maxY is a bottom
                    // minY is a top
                    
                    // height of one cell
//                    geometry.size.height
                }
            )
    }
}

// MARK: - Preview
struct TestPreferenceKeyView_Previews: PreviewProvider {
    static var previews: some View {
        TestPreferenceKeyView()
    }
}


// MARK: - Model and Fake data
struct SomeModel: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
}

struct FakeData {
    static let data = [
        SomeModel(text: "1", color: .blue),
        SomeModel(text: "2", color: .brown),
        SomeModel(text: "3", color: .clear),
        SomeModel(text: "4", color: .cyan),
        SomeModel(text: "5", color: .gray),
        SomeModel(text: "6", color: .green),
        SomeModel(text: "7", color: .indigo),
        SomeModel(text: "8", color: .mint),
        SomeModel(text: "9", color: .orange),
        SomeModel(text: "10", color: .pink),
        SomeModel(text: "11", color: .red),
        SomeModel(text: "12", color: .teal),
        SomeModel(text: "13", color: .yellow),
        SomeModel(text: "14", color: .blue)
    ]
}
