//
//  getAnswerClient.swift
//  geminiAI
//
//  Created by Talha Gergin on 10.01.2025.
//

import Foundation
enum NetworkError: Error{
    case badUrl
    case badRequest
    case invalidResponse
    case decodingerror
}
struct getAnswerClient {
    func postPrompt(prompt: String) async throws -> APIResponseModel {
        let geminiURL = APIEndpoint.baseURL// Gemini API endpoint
        
        guard let url = URL(string: geminiURL) else {
            throw NetworkError.badUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = APIEndpoint.headers
        
        // İstek body'sini oluştur
        let requestBody = createRequestBody(prompt: prompt)
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            print("Status Code: \(httpResponse.statusCode)") // Hata durumunu yazdır
            throw NetworkError.badRequest
        }
        
        do {
            let apiResponse = try JSONDecoder().decode(APIResponseModel.self, from: data)
            return apiResponse
        } catch let error as DecodingError {
            switch error {
            case .typeMismatch(let type, let context):
                print("Type mismatch error: \(type), \(context)")
            case .valueNotFound(let value, let context):
                print("Value not found error: \(value), \(context)")
            case .keyNotFound(let key, let context):
                print("Key not found error: \(key), \(context)")
            case .dataCorrupted(let context):
                print("Data corrupted error: \(context)")
            @unknown default:
                print("Unknown decoding error: \(error)")
            }
            throw error
        } catch {
            print("Hata oluştu: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func createRequestBody(prompt: String) -> [String: Any] {
            return [
                "contents": [
                    [
                        "parts": [
                            ["text": prompt]
                        ]
                    ]
                ]
            ]
        }
}
