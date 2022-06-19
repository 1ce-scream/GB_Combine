//: [Previous](@previous)

import Combine
import Foundation

/* 1. Реализовать пользовательский Publisher, который осуществляет рассылку
 значений примитивных типов
 */

let commonPublisher = ["christopher", "david" ,"matt", "peter", "jodie"].publisher

/* 2. Реализовать пользовательский Subscriber, который подписывается на Publisher
 из первого пункта задания и выполняет какие-либо действия над полученными значениями,
 после чего выводит результат в консоль.
 */

final class CustomSubscriber: Subscriber {
    typealias Input = String
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    func receive(_ input: String) -> Subscribers.Demand {
        let output = "Hello, \(input.capitalized)!"
        print(output)
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Completion recieved \(completion) \n")
    }
}

let customSubscriber = CustomSubscriber()
commonPublisher.subscribe(customSubscriber)

/* 3. Реализовать кастомный Subject, который хранит в себе текущее значение,
 используя тип CurrentValueSubject.
 */

struct CustomSwitch {
    enum State {
        case on, off
    }
    
    let subject = CurrentValueSubject<State, Never>(.off)
    
    func toggle() {
        subject.send(subject.value == .on ? .off : .on)
    }
}

let customSwitch = CustomSwitch()

customSwitch.subject.sink { switchState in
    print("Switch state is \(switchState)")
}

customSwitch.toggle()
customSwitch.toggle()
customSwitch.toggle()
customSwitch.subject.send(.off)


//: [Next](@next)
