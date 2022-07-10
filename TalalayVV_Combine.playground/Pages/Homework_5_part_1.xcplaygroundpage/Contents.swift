//: [Previous](@previous)

import Foundation
import Combine

private var cancellables = Set<AnyCancellable>()

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

    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "APIClient",
                                      qos: .default,
                                      attributes: .concurrent)
    
    func fetchAPOD(startDate: String,
                   endDate: String) -> AnyPublisher<APODResponse, Never> {
        return URLSession.shared
            .dataTaskPublisher(for: EndPoint.APOD(start: startDate, end: endDate).url)
            .receive(on: queue)
            .map{ $0.data }
            .decode(type: APODResponse.self, decoder: decoder)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

// MARK: - API client enums extension
extension APIClient {
    
    // Request types
    enum EndPoint {
        static let baseURL = URL(string: "https://api.nasa.gov/")!
        // MARK: Get your own key, it's free :) https://api.nasa.gov
        static let NASAKey = "okiOhFbD6p2D9D27aQTRMe5indoyyWOuo72CxLj5"
        
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
}

// MARK: - Tests

let apiClient = APIClient()
let startDate = "2022-06-17"
let endDate = "2022-06-19"

let subject = PassthroughSubject<APODResponse,Never>()

let smth = apiClient.fetchAPOD(startDate: startDate, endDate: endDate)
    .multicast(subject: subject)

let sub1 = smth
    .sink(receiveValue: { print("First subscriber get: \n \($0)") })
    
let sub2 = smth
    .sink(receiveValue: { print("Second subscriber get: \n \($0)") })

smth
    .connect()
    .store(in: &cancellables)

//: [Next](@next)
