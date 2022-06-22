//: [Previous](@previous)

import Foundation
import Combine

private var cancellables = Set<AnyCancellable>()

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

// MARK: - Logger for debugging
class TimeLogger: TextOutputStream {
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var now: String {
        formatter.string(from: Date.now) + " "
    }
    
    func write(_ string: String) {
        print("Logger: ", now,  string)
    }
}

// MARK: - API Client
class APIClient {
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "APIClient",
                                      qos: .default,
                                      attributes: .concurrent)
    
    func fetchAPOD(startDate: String, endDate: String) -> AnyPublisher<APODResponse, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: EndPoint.APOD(start: startDate, end: endDate).url)
            .receive(on: queue)
            .map{ $0.data }
            .decode(type: APODResponse.self, decoder: decoder)
            .mapError{ (error) -> Error in
                switch error {
                case is URLError:
                    return Error.unreachableAddress(
                        url: EndPoint.APOD(start: startDate, end: endDate).url
                    )
                case is DecodingError:
                    return Error.decodingError
                default:
                    return Error.invalidResponse
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchNEO(startDate: String, endDate: String) -> AnyPublisher<NeoResponse, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: EndPoint.NEO(start: startDate, end: endDate).url)
            .receive(on: queue)
            .map{ $0.data }
            .decode(type: NeoResponse.self, decoder: decoder)
            .mapError{ (error) -> Error in
                switch error {
                case is URLError:
                    return Error.unreachableAddress(
                        url: EndPoint.NEO(start: startDate, end: endDate).url
                    )
                case is DecodingError:
                    return Error.decodingError
                default:
                    return Error.invalidResponse
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchSkyInfo(startDate: String, endDate: String) -> AnyPublisher<(APODResponse,NeoResponse),Error> {
        precondition(!startDate.isEmpty && !endDate.isEmpty)

        let initialPublisher = fetchAPOD(startDate: startDate, endDate: endDate)

        return initialPublisher
            .combineLatest(fetchNEO(startDate: startDate, endDate: endDate))
            .eraseToAnyPublisher()
    }
    
    // MARK: Methods for test
    func testSkyInfo(startDate: String, endDate: String) -> AnyPublisher<(APOD,NeoResponse),Error> {
        let initialPublisher = fetchAPOD(startDate: startDate, endDate: endDate)
            .flatMap{ $0.publisher }
        
        return initialPublisher
            .zip(fetchNEO(startDate: startDate, endDate: endDate))
            .eraseToAnyPublisher()
    }
    
    func testConvert(startDate: String, endDate: String) -> AnyPublisher<APOD, Error> {
        fetchAPOD(startDate: startDate, endDate: endDate)
            .flatMap{ $0.publisher }
            .eraseToAnyPublisher()
    }
    
//    //Dictionary<String, NearEarthObject>
//    func testConvert2(startDate: String, endDate: String) -> AnyPublisher<[String : [NearEarthObject]], Error> {
//        fetchNEO(startDate: startDate, endDate: endDate)
//            .flatMap{ $0.nearEarthObjects.publisher }
//            .eraseToAnyPublisher()
////        Publishers.FlatMap<Publishers.SetFailureType<Publishers.Sequence<[String : [NearEarthObject]], Never>, APIClient.Error>, AnyPublisher<NeoResponse, APIClient.Error>>
//    }
}

// MARK: - API client enums extension
extension APIClient {
    
    // Request types
    enum EndPoint {
        static let baseURL = URL(string: "https://api.nasa.gov/")!
        static let NASAKey = "DEMO_KEY"
        
        case NEO(start: String, end: String)
        case APOD(start: String, end: String)
        
        var url: URL {
            switch self {
            case .NEO(let startDate, let endDate):
                var baseQueryURL = URLComponents(url: EndPoint.baseURL.appendingPathComponent("neo/rest/v1/feed"),
                                                 resolvingAgainstBaseURL: false)!
                baseQueryURL.queryItems = [
                    URLQueryItem(name: "api_key", value: EndPoint.NASAKey),
                    URLQueryItem(name: "start_date", value: startDate),
                    URLQueryItem(name: "end_date", value: endDate)
                ]
                return baseQueryURL.url!
            case .APOD(let startDate, let endDate):
                var baseQueryURL = URLComponents(url: EndPoint.baseURL.appendingPathComponent("planetary/apod"),
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
    enum Error: LocalizedError {
        case unreachableAddress(url: URL)
        case invalidResponse
        case decodingError
        
        var errorDescription: String? {
            switch self {
            case .unreachableAddress(let url):
                return "\(url.absoluteString) is unreachable"
            case .invalidResponse:
                return "Response with mistake"
            case .decodingError:
                return "Can't decode data"
            }
        }
    }
}

// MARK: - Tests (Everything work correctly)

let apiClient = APIClient()
let startDate = "2022-06-17"
let endDate = "2022-06-19"

//apiClient.fetchAPOD(startDate: startDate, endDate: endDate)
//    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
//    .store(in: &cancellables)
//
//apiClient.fetchNEO(startDate: startDate, endDate: endDate)
//    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
//    .store(in: &cancellables)

apiClient.fetchSkyInfo(startDate: startDate, endDate: endDate)
    .print("Sky info publisher", to: TimeLogger())
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &cancellables)

//apiClient.testSkyInfo(startDate: startDate, endDate: endDate)
//    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
//    .store(in: &cancellables)

//apiClient.testConvert(startDate: startDate, endDate: endDate)
//    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
//    .store(in: &cancellables)


// MARK: - Just an experiment to bring publishers together

//let stringArray = ["a","b","c","d"].publisher
//    .flatMap{$0.publisher}
//let integerArray = [1,2].publisher
//
//stringArray
//    .combineLatest(integerArray)
//    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
//    .store(in: &cancellables)
//
//stringArray
//    .zip(integerArray)
//    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
//    .store(in: &cancellables)
    
//: [Next](@next)
