//
//  StarWarsService.swift
//  Ravn-Challenge-V2-DanielCornejo
//
//  Created by Daniel Cornejo on 7/4/21.
//

import Combine
import Foundation

protocol StarWarsServiceType {
    func fetchFirstPeople() -> AnyPublisher<AllPeople, ApolloServiceError>
    func fetchMorePeople(using cursor: String?) -> AnyPublisher<AllPeople, ApolloServiceError>
}

struct StarWarsService: StarWarsServiceType {
    
    private let service: ApolloServiceType
    
    // MARK: - Init
    init(service: ApolloServiceType = ApolloService.shared) {
        self.service = service
    }
    
    // MARK: - StarWarsServiceType
    func fetchFirstPeople() -> AnyPublisher<AllPeople, ApolloServiceError> {
        service.fetch(StarWarsPeopleQuery(first: 5))
            .compactMap { $0.allPeople?.jsonObject }
            .tryCompactMap {
                try JSONSerialization.data(withJSONObject: $0, options: .withoutEscapingSlashes)
            }
            .decode(type: AllPeople.self, decoder: JSONDecoder())
            .mapError { ApolloServiceError(message: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    func fetchMorePeople(using cursor: String?) -> AnyPublisher<AllPeople, ApolloServiceError> {
        service.fetch(StarWarsPeopleQuery(first: 5, after: cursor))
            .compactMap { $0.allPeople?.jsonObject }
            .tryCompactMap {
                try JSONSerialization.data(withJSONObject: $0, options: .withoutEscapingSlashes)
            }
            .decode(type: AllPeople.self, decoder: JSONDecoder())
            .mapError { ApolloServiceError(message: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}
