import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    @State private var chatMessages: [ChatMessage] = []
    @State private var isSendingMessage = false
    @State private var geminiClient = getAnswerClient()
    @State private var isWaitingForResponse = false // "..." göstermek için durum ekledik

    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(chatMessages) { message in
                            ChatMessageView(message: message)
                        }
                        
                        // Eğer cevap bekleniyorsa, "..." mesajını göster
                        if isWaitingForResponse {
                            HStack {
                                Spacer()
                                Text("...")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .onAppear {
                        scrollToBottom(proxy: scrollViewProxy)
                    }
                    .onChange(of: chatMessages) { oldMessages, newMessages in
                        scrollToBottom(proxy: scrollViewProxy)
                    }
                }
            }
            
            HStack {
                TextField("Mesajınızı yazın...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isSendingMessage)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(isSendingMessage ? .gray : .blue)
                }
                .disabled(isSendingMessage || messageText.isEmpty)
            }
            .padding()
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessageId = chatMessages.last?.id {
            proxy.scrollTo(lastMessageId, anchor: .bottom)
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = ChatMessage(id: UUID(), text: messageText, isUser: true)
        chatMessages.append(userMessage)
        messageText = ""
        isSendingMessage = true
        isWaitingForResponse = true // Bekleme durumunu etkinleştir
        
        Task {
            do {
                let response = try await geminiClient.postPrompt(prompt: userMessage.text)
                if let textResponse = response.candidates.first?.content.parts.first?.text {
                    let geminiMessage = ChatMessage(id: UUID(), text: textResponse, isUser: false)
                    isWaitingForResponse = false // Bekleme durumunu kapat
                    chatMessages.append(geminiMessage)
                } else {
                    print("Gemini'den cevap alınamadı")
                    let errorMessage = ChatMessage(id: UUID(), text: "Gemini'den cevap alınamadı", isUser: false)
                    isWaitingForResponse = false
                    chatMessages.append(errorMessage)
                }
            } catch {
                print("API Hatası: \(error.localizedDescription)")
                let errorMessage = ChatMessage(id: UUID(), text: "API Hatası: \(error.localizedDescription)", isUser: false)
                isWaitingForResponse = false
                chatMessages.append(errorMessage)
            }
            isSendingMessage = false
        }
    }
}
