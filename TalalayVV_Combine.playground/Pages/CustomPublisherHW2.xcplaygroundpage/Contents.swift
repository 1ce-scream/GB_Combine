//: [Previous](@previous)

import Foundation
import Combine

struct Contact {
    let name: String
    let number: String
}

let contacts: [Contact] = [
    Contact(name: "Steve", number: "9992341213"),
    Contact(name: "Matt", number: "9612341213"),
    Contact(name: "Jodie", number: "3331233232"),
    Contact(name: "Boris3", number: "9118883344"),
    Contact(name: "John", number: "8881112233"),
    Contact(name: "Boris", number: "9118883344"),
    Contact(name: "Boris2", number: "9118883344"),
    Contact(name: "John", number: "9992349988")
]

struct CustomPublisher: Publisher {
    typealias Output = String
    typealias Failure = Never
    
    private let inputString: String
    private let contacts: [Contact]
    
    init(inputString: String, contacts: [Contact]) {
        self.inputString = inputString
        self.contacts = contacts
    }
    
    func receive<S>(
        subscriber: S
    ) where S : Subscriber, Never == S.Failure, String == S.Input {
        let subscription = CustomSubscription(subscriber: subscriber,
                                              input: inputString,
                                              contacts: contacts)
        subscriber.receive(subscription: subscription)
    }
}

final class CustomSubscription<S: Subscriber>: Subscription where S.Input == String {
    private var contacts: [Contact]
    private let inputString: String
    private var subscriber: S?
    
    init(subscriber: S?, input: String, contacts: [Contact]) {
        self.subscriber = subscriber
        self.inputString = input
        self.contacts = contacts
    }
    
    func request(_ demand: Subscribers.Demand) {
        
        guard inputString.count > .none else {
            subscriber?.receive(completion: .finished)
            return
        }
        
        var count = contacts.count
        
        while let subscriber = subscriber, count > 0 {
            for contact in contacts {
                if contact.name.lowercased().contains(inputString.lowercased()) {
                    subscriber.receive(contact.number)
                } else if contact.number.contains(inputString) {
                    subscriber.receive(contact.name)
                }
                count -= 1
            }
            
            if count == 0 {
                subscriber.receive(completion: .finished)
            }
        }
    }
    
    func cancel() {
        subscriber = nil
    }
}

let input = "John"
let input2 = "9118883344"

let customPublisher = CustomPublisher(inputString: input, contacts: contacts)
customPublisher
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })

//: [Next](@next)
