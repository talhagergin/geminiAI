//
//  Answer.swift
//  geminiAI
//
//  Created by Talha Gergin on 10.01.2025.
//

import Foundation

// MARK: - Model for the given JSON Response
struct APIResponseModel: Decodable {
    let candidates: [Candidate]
    let modelVersion: String
    let usageMetadata: UsageMetadata
}

struct Candidate: Decodable {
    let finishReason: String
    let index: Int
    let content: Content
}

struct Content: Decodable {
    let role: String
    let parts: [Part]
}

struct Part: Decodable {
    let text: String
}

struct UsageMetadata: Decodable {
    let candidatesTokenCount: Int
    let totalTokenCount: Int
    let promptTokenCount: Int
}
