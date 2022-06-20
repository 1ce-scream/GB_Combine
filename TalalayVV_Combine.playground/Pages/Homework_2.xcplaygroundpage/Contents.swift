//: [Previous](@previous)

import Foundation
import Combine

public func example(of description: String, action: () -> Void) {
    print("\n------ Example of:", description, "------\n")
    action()
}

// Subscriptions property.
private var subscriptions = Set<AnyCancellable>()

// Contacts 
struct Contact {
    let name: String
    let number: String
}

let contacts: [Contact] = [
    Contact(name: "Steve", number: "9992341213"),
    Contact(name: "Matt", number: "9612341213"),
    Contact(name: "Jodie", number: "3331233232"),
    Contact(name: "John", number: "8881112233"),
    Contact(name: "Boris", number: "9118883344")
]

/* 1. Создайте пример, который публикует коллекцию чисел от 1 до 100, и используйте
 операторы фильтрации, чтобы выполнить следующие действия:
    a. Пропустите первые 50 значений, выданных вышестоящим издателем.
    b. Возьмите следующие 20 значений после этих 50.
    c. Берите только чётные числа.
 */

example(of: "First task, option 1") {
    (1...100).publisher
        .dropFirst(50)
        .prefix(20)
        .filter{ $0 % 2 == 0 }
        .collect()
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0)})
        .store(in: &subscriptions)
}

example(of: "First task, option 2") {
    (1...100).publisher
        .filter {$0 > 50 && $0 <= 70 && $0 % 2 == 0}
        .collect()
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0)})
        .store(in: &subscriptions)
}


/* 2. Создайте пример, который собирает коллекцию строк, преобразует её в коллекцию чисел
и вычисляет среднее арифметическое этих значений.
 */

example(of: "Second task") {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    ["two", "forty-six", "sixty-nine", "hello", "not-a-number", "five"].publisher
        .compactMap{ formatter.number(from: $0) as? Int }
        .collect()
        .map{ Double($0.reduce(0, +)) / Double($0.count) }
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/* 3.Создать поиск телефонного номера в коллекции с помощью операторов преобразования,
 ваша цель в этой задаче — создать издателя, который делает две вещи:
    a. Получает строку из десяти цифр или букв.
    b. Ищет этот номер в структуре данных контактов.
 */

example(of: "Third task, option 1") {
    let name = "Boris"
    let number = "3331233232"
    
    contacts.publisher
        .compactMap{
            if $0.name.lowercased().contains(name.lowercased()) || $0.number.contains(number) {
                return $0
            } else {
                return nil
            }
        }
        .sink(receiveCompletion: { print($0)}, receiveValue: { print($0) })
}

example(of: "Third task, option 2") {
    let number = "3331233232"
    let publisher = PassthroughSubject<String,Never>()
    
    publisher
        .map{ input in
            var output: Contact?
            for contact in contacts {
                if contact.number.contains(input) {
                    output = contact
                    break
                } else {
                    output = nil
                }
            }
            return output
        }
        .compactMap{ $0 }
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publisher.send(number)
}

example(of: "Third task, option 2 short") {
    let number = "3331233232"
    let publisher = PassthroughSubject<String,Never>()
    
    publisher
        .compactMap{ input in
            contacts.first { $0.number.contains(input)}
        }
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publisher.send(number)
    
    print("Custom publisher on next page :)")
}
//: [Task 3 custom publisher](@next)
