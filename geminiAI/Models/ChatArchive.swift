//
//  ChatArchive.swift
//  geminiAI
//
//  Created by Talha Gergin on 10.01.2025.
//

import Foundation
import SwiftData

@Model
final class ChatArchive {
    var id: UUID
    var date: Date
    @Relationship(deleteRule: .cascade) var messages: [ArchivedMessage]
    
    init(date: Date, messages: [ArchivedMessage]) {
        self.id = UUID()
        self.date = date
        self.messages = messages
    }
}
