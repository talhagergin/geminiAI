//
//  ChatAnswer.swift
//  geminiAI
//
//  Created by Talha Gergin on 10.01.2025.
//
import Foundation

struct ChatMessage: Identifiable,Equatable {
    let id: UUID
    let text: String
    let isUser: Bool
    
}
