//
//  APIHandler.swift
//  NetworkLayerDemo
//
//  Created by Tai Chin Huang on 2024/4/7.
//

import Foundation
import Combine

struct ResponseWrapper<T: Decodable>: Decodable {
    let code: Int?
    let redirect: String?
    let data: T?
    let token: String?
    
    enum CodingKeys: CodingKey {
        case code
        case redirect
        case data
        case token
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decodeIfPresent(Int.self, forKey: .code)
        redirect = try container.decodeIfPresent(String.self, forKey: .redirect)
        data = try container.decodeIfPresent(T.self, forKey: .data)
        token = try container.decodeIfPresent(String.self, forKey: .token)
    }
}

struct HTTPMethod: RawRepresentable, Hashable, Equatable {
    
    static let connect = HTTPMethod(rawValue: "CONNECT")
    static let delete = HTTPMethod(rawValue: "DELETE")
    static let get = HTTPMethod(rawValue: "GET")
    static let head = HTTPMethod(rawValue: "HEAD")
    static let options = HTTPMethod(rawValue: "OPTIONS")
    static let patch = HTTPMethod(rawValue: "PATCH")
    static let post = HTTPMethod(rawValue: "POST")
    static let put = HTTPMethod(rawValue: "PUT")
    static let query = HTTPMethod(rawValue: "QUERY")
    static let trace = HTTPMethod(rawValue: "TRACE")
    
    let rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

enum APIHandlerError: Error {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
}

protocol APIHandlerProtocol {
    func request<T: Decodable>(endpoint: Endpoint, headers: [String: String]?, parameters: Encodable?) -> AnyPublisher<T, APIHandlerError>
}

class NetworkManager: APIHandlerProtocol {
    private let baseURL: String
    private let token: String
    private let decoder = JSONDecoder()
    
    init(environment: Environment = NetworkManager.defaultEnvironment()) {
        baseURL = environment.baseURL
        token = environment.token
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func request<T>(
        endpoint: Endpoint,
        headers: [String: String]? = nil,
        parameters: Encodable? = nil
    ) -> AnyPublisher<T, APIHandlerError> where T : Decodable {
        guard let url = URL(string: baseURL + endpoint.path) else {
            return Fail(error: APIHandlerError.invalidURL).eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.httpMethod.rawValue
        urlRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
        let allHeaders = defaultHeaders().merging(headers ?? [:]) { (_, new) in new }
            
        for (key, value) in allHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        if let parameters = parameters {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONEncoder().encode(parameters)
                urlRequest.httpBody = jsonData
            } catch {
                return Fail(error: APIHandlerError.requestFailed("Encoding parameters failed.")).eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { (data, response) -> Data in
                let rawJSON = String(data: data, encoding: .utf8) ?? "Invalid JSON"
//                print("\n=============== rawJSON starting ================")
//                dump(rawJSON)
//                print("=============== rawJSON ending ================\n")
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    let stateCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    throw APIHandlerError.requestFailed("Request failed with status code: \(stateCode)")
                }
                return data
            }
            .decode(type: ResponseWrapper<T>.self, decoder: decoder)
            .tryMap { responseWrapper -> T in
                guard let stateCode = responseWrapper.code else {
                    throw APIHandlerError.requestFailed("Missing state code.")
                }
                switch stateCode {
                case 200:
                    guard let data = responseWrapper.data else {
                        throw APIHandlerError.requestFailed("Missing data.")
                    }
                    return data
                default:
                    let message = responseWrapper.redirect ?? "An error occurred."
                    throw APIHandlerError.requestFailed(message)
                }
            }
            .mapError { error -> APIHandlerError in
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for type \(type): \(context)")
                    case .valueNotFound(let type, let context):
                        print("Value not found for type \(type): \(context)")
                    case .keyNotFound(let key, let context):
                        print("Key '\(key.stringValue)' not found: \(context)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context)")
                    @unknown default:
                        print("Unknown error")
                    }
                    return APIHandlerError.decodingFailed
                } else if let apiError = error as? APIHandlerError {
                    return apiError
                } else {
                    return APIHandlerError.requestFailed("An unknown error occurred.")
                }
            }
            .eraseToAnyPublisher()
    }
    
    static func defaultEnvironment() -> Environment {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }
    
    private func defaultHeaders() -> [String: String] {
        var headers: [String: String] = [
            "Platform": "iOS",
            "User-Token": "your_user_token",
            "uid": "user-id"
        ]
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            headers["App-Version"] = appVersion
        }
        
        return headers
    }
}

enum Environment {
    case development
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development: return "https://webt.vivatv.com.tw"
        case .staging: return "https://www.vivatv.com.tw"
        case .production: return "https://www.vivatv.com.tw"
        }
    }
    
    var token: String {
        switch self {
        case .development:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJncm91cF9jb2RlIjoid2ViIiwiZW52IjoiZGV2IiwicmFuZG9tIjowLjAxOTQ3MzUzNzQ3NTg0NzY4LCJpc3MiOiJ2aXZhIGVjIiwic3ViamVjdCI6ImFjY2VzcyBjb250cm9sIiwiaWF0IjoxNzAzNzQ4MDA3LCJleHAiOjE3MzUyODQwMDd9.ep9DtjnF6Vy5n9EBAdFBqrmSr4GG-1t-3a8hYH8VKH4"
        case .staging:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJncm91cF9jb2RlIjoid2ViIiwiZW52IjoicHJvZCIsInJhbmRvbSI6MC4xNDIwNDE5MDQ1NTE0NTIyNywiaXNzIjoidml2YSBlYyIsInN1YmplY3QiOiJhY2Nlc3MgY29udHJvbCIsImlhdCI6MTcwMjk1NTc2OCwiZXhwIjoxNzM0NDkxNzY4fQ.jWOqUQ-nhIL18CToO8Ybeh-teXefg1lCzR242Y5ooCE"
        case .production:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJncm91cF9jb2RlIjoid2ViIiwiZW52IjoicHJvZCIsInJhbmRvbSI6MC4xNDIwNDE5MDQ1NTE0NTIyNywiaXNzIjoidml2YSBlYyIsInN1YmplY3QiOiJhY2Nlc3MgY29udHJvbCIsImlhdCI6MTcwMjk1NTc2OCwiZXhwIjoxNzM0NDkxNzY4fQ.jWOqUQ-nhIL18CToO8Ybeh-teXefg1lCzR242Y5ooCE"
        }
    }
}
