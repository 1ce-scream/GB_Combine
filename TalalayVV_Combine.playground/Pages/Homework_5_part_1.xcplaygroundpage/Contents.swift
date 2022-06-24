//: [Previous](@previous)

import Foundation
import Combine

public func example(of description: String, action: () -> Void) {
    print("\n------ Example of:", description, "------\n")
    action()
}

// Subscriptions property.
private var subscriptions = Set<AnyCancellable>()

example(of: "Homework_5") {
    print("Look at SlotsMachine")
}
//: [Next](@next)
