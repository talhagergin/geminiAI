//
//  ArchivedMessage.swift
//  geminiAI
//
//  Created by Talha Gergin on 10.01.2025.
//
import Foundation
import SwiftData

@Model
final class ArchivedMessage {
    var id: UUID
    var text: String
    var isUser: Bool
    
    init(text: String, isUser: Bool) {
        self.id = UUID()
        self.text = text
        self.isUser = isUser
    }
}
