import SwiftUI
import SwiftData

struct ChatArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var chatArchives: [ChatArchive]
    
    var body: some View {
        NavigationView {
            List(chatArchives) { archive in
                NavigationLink(destination: ChatDetailView(chatArchive: archive)) {
                    Text("Sohbet - \(archive.date.formatted(.dateTime))")
                }
            }
            .navigationTitle("Arşivlenmiş Sohbetler")
        }
        .onAppear {
            // Verilerin yüklenmesi için query'nin tetiklenmesi gerekmiyor çünkü @Query otomatik olarak çalışır.
        }
    }
}
