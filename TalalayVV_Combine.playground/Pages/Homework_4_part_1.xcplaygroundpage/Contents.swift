//: [Previous](@previous)

import Foundation
import Combine

private var cancellables = Set<AnyCancellable>()

/*
1. Написать простейший клиент, который обращается к любому открытому API, используя Combine в запросах. (Минимальное количество методов API: 2).
2. Реализовать отладку любых двух издателей в коде.
*/

// MARK: Models
struct PageInfo: Codable {
    private let count: Int
    private let pages: Int
    private let prev: String?
    private let next: String?

    init(count: Int, pages: Int, prev: String?, next: String?) {
        self.count = count
        self.pages = pages
        self.prev = prev
        self.next = next }
}

// MARK: - Character models
struct Character: Codable {
    private let id: Int64
    private let name: String
    private let status: String
    private let species: String
    private let type: String
    private let gender: String
    private let image: String
    
    init(id: Int64, name: String, status: String, species: String, type: String, gender: String, image: String) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.image = image
    }
}

struct CharacterPage: Codable {
    private let info: PageInfo
    private let results: [Character]
    
    init(info: PageInfo, results: [Character]) {
        self.info = info
        self.results = results
    }
}

// MARK: - Episode models
struct Episode: Codable {
    private let id: Int
    private let name: String
    private let airDate: String
    private let episode: String
    
    enum CodingKeys: String, CodingKey{
        case id = "id"
        case name = "name"
        case airDate = "air_date"
        case episode = "episode"
    }
   
    init(id: Int, name: String, airDate: String, episode: String) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.episode = episode
    }
}

struct EpisodePage: Codable {
    private let info: PageInfo
    private let results: [Episode]
    
    init(info: PageInfo, results: [Episode]) {
        self.info = info
        self.results = results
    }
}


// MARK: - Logger for debugging
class TimeLogger: TextOutputStream {
    
    private var previous = Date()
    private let formatter = NumberFormatter()
    
    init() {
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 5
    }
    
    func write(_ string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let now = Date()
        print("+\(formatter.string(for: now.timeIntervalSince(previous))!)s: \(string)")
        previous = now
    }
}

// MARK: - Rick and Morty API client
struct APIClientRM {
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "APIClientRM",
                                      qos: .default,
                                      attributes: .concurrent)
    
    func fetchCharacter(id: Int) -> AnyPublisher<Character, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: EndPoint.character(id).url)
            .receive(on: queue)
            .map(\.data)
            .decode(type: Character.self, decoder: decoder)
            .mapError{ (error) -> APIError in
                switch error {
                case is URLError:
                    return APIError.unreachableAddress(url: EndPoint.character(id).url)
                default:
                    return APIError.invalidResponse
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchEpisode(id: Int) -> AnyPublisher<Episode, APIError> {
        return URLSession.shared
            .dataTaskPublisher(for: EndPoint.episode(id).url)
            .receive(on: queue)
            .map{ $0.data }
            .decode(type: Episode.self, decoder: decoder)
            .mapError({ error -> APIError in
                switch error {
                case is URLError:
                    return APIError.unreachableAddress(url: EndPoint.episode(id).url)
                default:
                    return APIError.invalidResponse
                }
            })
            .eraseToAnyPublisher()
    }
    
    func fetchSeveralEpisodes(ids: [Int]) -> AnyPublisher<Episode, APIError> {
        precondition(!ids.isEmpty)
        
        let initialPublisher = fetchEpisode(id: ids[0])
        let remainder = Array(ids.dropFirst())
        
        return remainder.reduce(initialPublisher) { (combined, id) in
            return combined
                .merge(with: fetchEpisode(id: id))
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Enums extension to APIClientRM
extension APIClientRM {
    
    // Request types
    enum EndPoint {
        static let baseURL = URL(string: "https://rickandmortyapi.com/api/")!
        
        case character(Int)
        case episode(Int)
        
        var url: URL {
            switch self {
            case .character(let id):
                return EndPoint.baseURL.appendingPathComponent("character/\(id)")
            case .episode(let id):
                return EndPoint.baseURL.appendingPathComponent("episode/\(id)")
            }
        }
    }
    
    // Error types
    enum APIError: Error, LocalizedError {
        case unreachableAddress(url: URL)
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .unreachableAddress(let url):
                return "\(url.absoluteString) is unreachable"
            case .invalidResponse:
                return "Response with mistake"
            }
        }
    }
}

// MARK: - Tests
let apiClient = APIClientRM()

apiClient.fetchCharacter(id: 10)
    .print("Character publisher", to: TimeLogger())
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &cancellables)

apiClient.fetchEpisode(id: 8)
    .print("Episode publisher", to: TimeLogger())
    .handleEvents(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print(error.localizedDescription)
            }
        }
    )
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &cancellables)

apiClient.fetchSeveralEpisodes(ids: [1,10,50,60])
    .handleEvents(
        receiveSubscription: { print("Subs: \($0)") },
        receiveOutput: { print("Output: \($0)") },
        receiveCancel: { print("Subs was canceled") },
        receiveRequest: { print("Subs demand: \($0)") })
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

//: [Next](@next)
