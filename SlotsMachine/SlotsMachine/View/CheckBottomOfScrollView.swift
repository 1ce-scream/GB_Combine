//
//  CheckScrollViewSize.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 11.07.2022.
//

import SwiftUI

// MARK: - Preference Key
struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}

struct SizePreferenceKey: PreferenceKey {
  typealias Value = CGSize
  static var defaultValue: Value = .zero

  static func reduce(value _: inout Value, nextValue: () -> Value) {
    _ = nextValue()
  }
}

struct ChildSizeReader<Content: View>: View {
  @Binding var size: CGSize

  let content: () -> Content
  var body: some View {
    ZStack {
      content().background(
        GeometryReader { proxy in
          Color.clear.preference(
            key: SizePreferenceKey.self,
            value: proxy.size
          )
        }
      )
    }
    .onPreferenceChange(SizePreferenceKey.self) { preferences in
      self.size = preferences
    }
  }
}

// MARK: - View

struct CheckScrollViewSize: View {
    let spaceName = "scroll"

    @State var wholeSize: CGSize = .zero
    @State var scrollViewSize: CGSize = .zero

    var body: some View {
        ChildSizeReader(size: $wholeSize) {
            ScrollView {
                ChildSizeReader(size: $scrollViewSize) {
                    VStack {
                        ForEach(0..<100) { i in
                            Text("\(i)")
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ViewOffsetKey.self,
                                value: -1 * proxy.frame(in: .named(spaceName)).origin.y
                            )
                        }
                    )
                    .onPreferenceChange(
                        ViewOffsetKey.self,
                        perform: { value in
                            print("offset: \(value)") // offset: 1270.3333333333333 when User has reached the bottom
                            print("height: \(scrollViewSize.height)") // height: 2033.3333333333333

                            if value >= scrollViewSize.height - wholeSize.height {
                                print("User has reached the bottom of the ScrollView.")
                            } else {
                                print("not reached.")
                            }
                        }
                    )
                }
            }
            .coordinateSpace(name: spaceName)
        }
        .onChange(
            of: scrollViewSize,
            perform: { value in
                print(value)
            }
        )
    }
}

struct CheckScrollViewSize_Previews: PreviewProvider {
    static var previews: some View {
        CheckScrollViewSize()
    }
}

