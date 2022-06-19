//: [Previous](@previous)

import Combine
import Foundation

struct CustomPublisher: Publisher {
    typealias Output = Int
    typealias Failure = Never
    
    private let configuration: CustomConfiguration
    
    init(configuration: CustomConfiguration) {
        self.configuration = configuration
    }
    
    func receive<S>(
        subscriber: S
    ) where S : Subscriber, Never == S.Failure, Int == S.Input {
        let subscription = CustomSubscription(subscriber: subscriber,
                                              configuration: configuration)
        subscriber.receive(subscription: subscription)
    }
}

struct CustomConfiguration {
    var count: Int
}

final class CustomSubscription<S: Subscriber>: Subscription where S.Input == Int {
    private let configuration: CustomConfiguration
    private var count: Int
    private var subscriber: S?
    // subscribers need
    private var requested: Subscribers.Demand = .none
    
    init(subscriber: S?, configuration: CustomConfiguration) {
        self.subscriber = subscriber
        self.configuration = configuration
        self.count = configuration.count
    }
    
    func request(_ demand: Subscribers.Demand) {
        
        // Do some logic e.g.
        guard count > .none else {
            subscriber?.receive(completion: .finished)
            return
        }
        
        requested += demand
        
        guard let _ = subscriber, requested > .none else { return }
        
        while let subscriber = subscriber, requested > .none {

            requested += subscriber.receive(count)
            count -= 1
            requested -= .max(1)
            
            if count == 0 {
                subscriber.receive(completion: .finished)
                return
            }
        }
    }
    
    func cancel() {
        subscriber = nil
    }
}

extension Publishers {
    private static func customPublisher(configuration: CustomConfiguration) -> CustomPublisher {
        CustomPublisher(configuration: configuration)
    }
    
    static func customPublisher(count: Int = 6) -> CustomPublisher {
        CustomPublisher(configuration: CustomConfiguration(count: count))
    }
}

Publishers.customPublisher(count: 10)
    .sink { value in
//        print(value, terminator: " ")
        print (value)
    }

final class CustomSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never

    var limit: Subscribers.Demand

    init(limit: Subscribers.Demand) {
        self.limit = limit
    }

    func receive(subscription: Subscription) {
        subscription.request(limit)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        .none
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        print("Subscriber's completion: \(completion)")
    }
}

let subscriber = CustomSubscriber(limit: .max(3))

Publishers.customPublisher(count: 10)
    .print()
    .subscribe(subscriber)

/*
 used articles
 https://habr.com/ru/post/482690/
 https://betterprogramming.pub/how-to-create-custom-publishers-in-combine-if-you-really-need-them-5bfab31b4ade
 */

//: [Homework 2](@next)
