//
//  OCSAPIService.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 12/09/2021.
//

import Foundation
import Alamofire

class OCSAPIService: APIService {
    func fetchPrograms(query: String, completion: @escaping (Result<Programs, OCSAPIError>) -> ()) {
        getRequest(endpoint: .searchPrograms(title: query.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? ""), completion: completion)
    }
    
    func fetchProgramDetails(detailUrl: String, completion: @escaping (Result<ProgramDetail, OCSAPIError>) -> ()) {
        getRequest(endpoint: .getProgramContent(detaillink: detailUrl), completion: completion)
    }
    
    private func getRequest<T: Decodable>(endpoint: OCSAPIEndpoint, completion: @escaping (Result<T, OCSAPIError>) -> ()) {
        guard let url = URL(string: endpoint.url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("URL appelée: \(url.absoluteString)")
        
        AF.request(url).validate().responseDecodable(of: T.self) { response in
            switch response.result {
            case .success:
                guard let data = response.value else {
                    completion(.failure(.downloadError))
                    return
                }
                
                completion(.success(data))
            case let .failure(error):
                guard let httpResponse = response.response else {
                    print("ERREUR: \(error)")
                    completion(.failure(.networkError))
                    return
                }
                
                switch httpResponse.statusCode {
                case 400:
                    completion(.failure(.badRequest))
                case 403:
                    completion(.failure(.forbidden))
                case 404:
                    completion(.failure(.notFound))
                case 500:
                    completion(.failure(.serverError))
                default:
                    completion(.failure(.unknown))
                }
            }
        }
    }
}
