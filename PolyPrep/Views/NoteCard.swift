import SwiftUI

struct NoteCard: View {
    let note: Note
    @State private var isLiked = false
    @State private var isExpanded = false
    @State private var likesCount: Int
    @State private var textHeight: CGFloat = 0
    @Binding var savedNotes: [Note]
    
    init(note: Note, savedNotes: Binding<[Note]>) {
        self.note = note
        self._savedNotes = savedNotes
        self._likesCount = State(initialValue: note.likesCount)
    }
    
    // Используем computed property для синхронизации состояния сохранения
    private var isSaved: Bool {
        savedNotes.contains(where: { $0.id == note.id })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок, дата и кнопка сохранения
            HStack {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(note.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Button(action: {
                        withAnimation {
                            toggleSaveNote()
                        }
                    }) {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(isSaved ? .yellow : .white)
                            .overlay(
                                Image(systemName: "bookmark")
                                    .foregroundColor(.black)
                            )
                    }
                }
            }
            
            // Автор
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.black)
                Text(note.author)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            
            // Контент
            Button(action: {
                if textHeight > 60 {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }) {
                Text(note.content + (textHeight > 60 && !isExpanded ? "..." : ""))
                    .font(.body)
                    .foregroundColor(.black)
                    .lineLimit(isExpanded ? nil : 3)
                    .multilineTextAlignment(.leading)
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                textHeight = geometry.size.height
                            }
                        }
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Нижняя часть с кнопками
            HStack(spacing: 16) {
                // Кнопка лайка
                Button(action: {
                    withAnimation {
                        isLiked.toggle()
                        likesCount += isLiked ? 1 : -1
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundColor(isLiked ? .blue : .black)
                        Text("\(likesCount)")
                            .foregroundColor(.black)
                    }
                }
                
                // Кнопка комментариев
                Button(action: {
                    // Действие для комментариев
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.black)
                        Text("\(note.commentsCount)")
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                // Кнопка шаринга
                Button(action: {
                    shareNote()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private func toggleSaveNote() {
        if isSaved {
            // Если заметка уже сохранена, удаляем её из сохраненных
            savedNotes.removeAll(where: { $0.id == note.id })
        } else {
            // Если заметка не сохранена, добавляем её в сохраненные
            savedNotes.append(note)
        }
    }
    
    private func shareNote() {
        let noteText = "\(note.title)\n\(note.content)"
        let activityVC = UIActivityViewController(activityItems: [noteText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    NoteCard(note: Note(
        author: "Макс Пупкин",
        date: Date(),
        title: "Конспекты по кмзи от Пупки Лупкиной",
        content: "Представляю вам свои гадкие конспекты по вышматы или не вышмату не знаб но не по кмзи точно",
        likesCount: 1,
        commentsCount: 0
    ), savedNotes: .constant([]))
} 