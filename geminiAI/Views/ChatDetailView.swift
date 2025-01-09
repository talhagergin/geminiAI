//
//  ChatDetailView.swift
//  geminiAI
//
//  Created by Talha Gergin on 10.01.2025.
//
import SwiftUI

struct ChatDetailView: View {
    var chatArchive: ChatArchive

    var body: some View {
        VStack {
            Text("Sohbet Tarihi: \(chatArchive.date.formatted(.dateTime))")
                .font(.headline)
                .padding()

            List(chatArchive.messages) { message in
                Text("\(message.isUser ? "Kullanıcı" : "Gemini"): \(message.text)")
            }
        }
        .navigationTitle("Sohbet Detayı")
        .padding()
    }
}
