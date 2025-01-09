import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var messageText = ""
    @State private var chatMessages: [ChatMessage] = []
    @State private var isSendingMessage = false
    @State private var showAlert = false
    @State private var geminiClient = getAnswerClient()
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack {
                            ForEach(chatMessages) { message in
                                ChatMessageView(message: message)
                            }
                        }
                        .onAppear {
                            scrollToBottom(proxy: scrollViewProxy)
                        }
                        .onChange(of: chatMessages) { _ in
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
                            .foregroundColor(isSendingMessage ? .gray : .white)
                    }
                    .disabled(isSendingMessage || messageText.isEmpty)
                }
                .padding()

                if isLoading {
                    HStack {
                        Spacer()
                        Text("...")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                }
            }
            .navigationTitle("Sohbet")
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    showAlert = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                        .padding(10)
                }
                .disabled(chatMessages.isEmpty)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Sohbeti Kaydetmek İster Misiniz?"),
                        primaryButton: .default(Text("Evet")) {
                            saveChatToArchive()
                            clearChatMessages()
                        },
                        secondaryButton: .cancel()
                    )
                }

                NavigationLink(destination: ChatArchiveView()) {
                    Image(systemName: "archivebox.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                        .padding(10)
                }
            })
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
        isLoading = true

        Task {
            do {
                let response = try await geminiClient.postPrompt(prompt: userMessage.text)
                if let textResponse = response.candidates.first?.content.parts.first?.text {
                    let geminiMessage = ChatMessage(id: UUID(), text: textResponse, isUser: false)
                    chatMessages.append(geminiMessage)
                } else {
                    let errorMessage = ChatMessage(id: UUID(), text: "Gemini'den cevap alınamadı", isUser: false)
                    chatMessages.append(errorMessage)
                }
            } catch {
                let errorMessage = ChatMessage(id: UUID(), text: "API Hatası: \(error.localizedDescription)", isUser: false)
                chatMessages.append(errorMessage)
            }
            isSendingMessage = false
            isLoading = false
        }
    }

    func saveChatToArchive() {
        let messages = chatMessages.map { message in
            ArchivedMessage(text: message.text, isUser: message.isUser)
        }
        let chatArchive = ChatArchive(date: Date(), messages: messages)

        do {
            modelContext.insert(chatArchive)
            try modelContext.save()
        } catch {
            print("Sohbet kaydedilemedi: \(error.localizedDescription)")
        }
    }

    func clearChatMessages() {
        chatMessages.removeAll()
    }
}
