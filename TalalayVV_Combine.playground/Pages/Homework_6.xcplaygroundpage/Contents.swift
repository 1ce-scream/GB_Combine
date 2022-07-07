//: [Previous](@previous)

import Foundation
import Combine

private var cancellables = Set<AnyCancellable>()

/*
 1. Реализовать обработку ошибок внутри созданного на прошлом уроке API клиента.
 */
// MARK: - Near Earth Objects models
struct NeoResponse: Codable {
    let elementCount: Int
    let nearEarthObjects: [String: [NearEarthObject]]
    
    enum CodingKeys: String, CodingKey {
        case elementCount = "element_count"
        case nearEarthObjects = "near_earth_objects"
    }
}

extension NeoResponse: CustomStringConvertible {
    var description: String {
        return "\n Astronomy objects count: \(elementCount) \n Objects: \n \(nearEarthObjects)"
    }
}

struct NearEarthObject: Codable {
    let name: String
    let nasaJplURL: String
    let isPotentiallyHazardousAsteroid: Bool
    let isSentryObject: Bool
    
    enum CodingKeys: String, CodingKey {
        case name
        case nasaJplURL = "nasa_jpl_url"
        case isPotentiallyHazardousAsteroid = "is_potentially_hazardous_asteroid"
        case isSentryObject = "is_sentry_object"
    }
}

extension NearEarthObject: CustomStringConvertible {
    var description: String {
        return "\n Name: \(name), isHazardous: \(isPotentiallyHazardousAsteroid), isSentry: \(isSentryObject), \n NASA info \(nasaJplURL) \n"
    }
}

// MARK: - Astronomy Picture of a Day model

typealias APODResponse = [APOD]

struct APOD: Codable {
    let date: String
    let explanation: String
    let hdurl: String?
    let mediaType: String
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case date
        case explanation
        case hdurl
        case mediaType = "media_type"
        case title
        case url
    }
}

extension APOD: CustomStringConvertible {
    var description: String { return " \n Date: \(date) \n Title: \(title). \n Explanation: \n \(explanation) \n Media type: \(mediaType) \n Media urls: \n \(url) \n \(hdurl ?? "") \n"}
}

// MARK: - API Client
class APIClient {
    typealias asteroids = (key: String, value: [NearEarthObject])
    
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "APIClient",
                                      qos: .default,
                                      attributes: .concurrent)
    
    // mapError first option
    func fetchAPOD(startDate: String,
                   endDate: String) -> AnyPublisher<APODResponse, APIError> {
        return URLSession.shared
            .dataTaskPublisher(for: EndPoint.APOD(start: startDate, end: endDate).url)
            .receive(on: queue)
            .map{ $0.data }
            .decode(type: APODResponse.self, decoder: decoder)
            .mapError{ (error) -> APIError in
                switch error {
                case is URLError:
                    return APIError.fetchingError
                case is DecodingError:
                    return APIError.decodingError
                default:
                    return APIError.unknownError
                }
            }
            .eraseToAnyPublisher()
    }
    
    // mapError second option
    func fetchNEO(startDate: String,
                  endDate: String) -> AnyPublisher<NeoResponse, APIError> {
        return URLSession.shared
            .dataTaskPublisher(for: EndPoint.NEO(start: startDate, end: endDate).url)
            .mapError{ error -> APIError in return APIError.fetchingError}
            .receive(on: queue)
            .map{ $0.data }
            .decode(type: NeoResponse.self, decoder: decoder)
            .mapError{ error -> APIError in
                return error as? APIError ?? .decodingError
            }
            .eraseToAnyPublisher()
    }
    
    func fetchSkyInfo(startDate: String,
                      endDate: String) -> AnyPublisher<(APOD,asteroids),APIError> {
        let initialPublisher = fetchAPOD(startDate: startDate, endDate: endDate)
            .flatMap{ $0.publisher }
        
        return initialPublisher
            .zip(
                fetchNEO(startDate: startDate, endDate: endDate)
                    .flatMap { value in
                        value.nearEarthObjects.sorted{ $0.key < $1.key }.publisher
                    }
            )
            .eraseToAnyPublisher()
    }
}

// MARK: - API client enums extension
extension APIClient {
    
    // Request types
    enum EndPoint {
        static let baseURL = URL(string: "https://api.nasa.gov/")!
        // MARK: Get your own key, it's free :) https://api.nasa.gov
        static let NASAKey = "DEMO_KEY"
        
        case NEO(start: String, end: String)
        case APOD(start: String, end: String)
        
        var url: URL {
            switch self {
            case .NEO(let startDate, let endDate):
                var baseQueryURL = URLComponents(
                    url: EndPoint.baseURL.appendingPathComponent("neo/rest/v1/feed"),
                    resolvingAgainstBaseURL: false)!
                
                baseQueryURL.queryItems = [
                    URLQueryItem(name: "api_key", value: EndPoint.NASAKey),
                    URLQueryItem(name: "start_date", value: startDate),
                    URLQueryItem(name: "end_date", value: endDate)
                ]
                return baseQueryURL.url!
                
            case .APOD(let startDate, let endDate):
                var baseQueryURL = URLComponents(
                    url: EndPoint.baseURL.appendingPathComponent("planetary/apod"),
                    resolvingAgainstBaseURL: false)!
                
                baseQueryURL.queryItems = [
                    URLQueryItem(name: "api_key", value: EndPoint.NASAKey),
                    URLQueryItem(name: "start_date", value: startDate),
                    URLQueryItem(name: "end_date", value: endDate)
                ]
                return baseQueryURL.url!
            }
        }
    }
    
    // Error types
    enum APIError: Error, LocalizedError {
        case fetchingError
        case decodingError
        case unknownError
        
        var errorDescription: String? {
            switch self {
            case .fetchingError:
                return "Can't fetch data from server"
            case .decodingError:
                return "Can't decode data"
            case .unknownError:
                return "Something went wrong"
            }
        }
    }
}

let apiClient = APIClient()
let startDate = "2022-06-17"
let endDate = "2022-06-19"

apiClient.fetchSkyInfo(startDate: startDate, endDate: endDate)
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print(error.localizedDescription)
            } else {
                print(completion)
            }
        },
        receiveValue: { print($0) }
    )
    .store(in: &cancellables)


//2. *Создать пользовательский издатель «трансформатор» по примеру «производителя»

extension Publisher {
    func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == Optional<T> {
        compactMap { $0 }
    }
    
    // first option
    func evenSquared() -> AnyPublisher<Output, Failure> where Output == Int {
        return filter {
            $0 % 2 == 0
        }.map {
            $0 * $0
        }.eraseToAnyPublisher()
    }
    
    // second option
    func isEven() -> AnyPublisher<Bool, Failure> where Output == Int {
        return map {
            $0 % 2 == 0
        }.eraseToAnyPublisher()
    }
}

let subA: () = [1,2,3,4,5,6,7,8,9].publisher
    .evenSquared()
    .sink(receiveValue: { print($0) } )
    .store(in: &cancellables)

let subB: () = [1,2,3,4,5,6,7,8,9].publisher
    .isEven()
    .sink(receiveValue: { print($0) } )
    .store(in: &cancellables)


//3. *Реализовать буферизируемый оператор sink.

final class BufferedSubscriber<Input, Failure: Error>: Subscriber {
    let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    let receiveValue: ([Input]) -> Input
    let capacity: Int
    
    var buffer: [Input] = []
    
    init(capacity: Int,
         receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
         receiveValue: @escaping (([Input]) -> Input)
    ) {
        self.capacity = capacity
        self.receiveCompletion = receiveCompletion
        self.receiveValue = receiveValue
    }
    
    //указывает количество значений, которые может получить наш подписчик
    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }
    
    //обрабатывает полученный ввод и расширяет количество значений, которые может получить подписчик.
    func receive(_ input: Input) -> Subscribers.Demand {
        buffer.append(input)
        if buffer.count > capacity {
            buffer.removeFirst()
//            buffer.removeAll()
        }
        if buffer.count == capacity {
            receiveValue(buffer)
        }
//        if buffer.count == capacity {
//            buffer.forEach { value in
//                receiveValue(value)
//            }
//        }
        
//        return .max(capacity)
        return .unlimited
    }
    
    //который обрабатывает событие завершения
    func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
        self.buffer.removeAll()
    }
}

extension Publisher {
    func bufferedSink(capacity: Int,
                      receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void),
                      receiveValue: @escaping (([Output]) -> Output)) {
        let buffered = BufferedSubscriber(capacity: capacity,
                                          receiveCompletion: receiveCompletion,
                                          receiveValue: receiveValue)
        self.subscribe(buffered)
    }
}

let subscription: () = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].publisher
    .bufferedSink(
        capacity: 6,
        receiveCompletion: { completion in
            print("Buffered subscription completed: \(completion)")
        },
        receiveValue: { value in
            print(value)
        }
    )

let subscrition2: () = [1,2,3,4,5,6,7,8,9,10,11,12].publisher
    .buffer(size: 6, prefetch: .keepFull, whenFull: .dropOldest)
    .sink(receiveValue: { print($0) } )
    .store(in: &cancellables)

//: [Next](@next)
