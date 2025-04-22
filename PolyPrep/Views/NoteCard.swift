import SwiftUI

struct NoteCard: View {
    let note: Note
    @State private var isExpanded = false
    @State private var textHeight: CGFloat = 0
    @State private var hashtagColors: [Color]
    @Binding var savedNotes: [Note]
    @ObservedObject var notesManager: NotesManager
    @State private var showComments = false
    
    // Используем computed property для синхронизации состояния лайка
    private var isLiked: Bool {
        if let savedNote = savedNotes.first(where: { $0.id == note.id }) {
            return savedNote.isLiked
        }
        return note.isLiked
    }
    
    private var likesCount: Int {
        if let savedNote = savedNotes.first(where: { $0.id == note.id }) {
            return savedNote.likesCount
        }
        return note.likesCount
    }
    
    init(note: Note, savedNotes: Binding<[Note]>, notesManager: NotesManager) {
        self.note = note
        self._savedNotes = savedNotes
        self.notesManager = notesManager
        self._hashtagColors = State(initialValue: Self.generateRandomColors(count: note.hashtags.count))
    }
    
    private static func generateRandomColors(count: Int) -> [Color] {
        return (0..<count).map { _ in
            Color(
                red: Double.random(in: 0...1),
                green: Double.random(in: 0...1),
                blue: Double.random(in: 0...1)
            )
        }
    }
    
    private func textColor(for backgroundColor: Color) -> Color {
        let components = backgroundColor.cgColor?.components ?? [0, 0, 0, 1]
        let brightness = (components[0] * 299 + components[1] * 587 + components[2] * 114) / 1000
        return brightness > 0.5 ? .black : .white
    }
    
    private var isSaved: Bool {
        savedNotes.contains(where: { $0.id == note.id })
    }
    
    private func toggleLike() {
        if isSaved {
            if let index = savedNotes.firstIndex(where: { $0.id == note.id }) {
                var updatedNote = savedNotes[index]
                updatedNote.isLiked.toggle()
                updatedNote.likesCount += updatedNote.isLiked ? 1 : -1
                savedNotes[index] = updatedNote
                notesManager.updateNoteLikes(noteId: note.id, isLiked: updatedNote.isLiked, likesCount: updatedNote.likesCount)
            }
        } else {
            var updatedNote = note
            updatedNote.isLiked.toggle()
            updatedNote.likesCount += updatedNote.isLiked ? 1 : -1
            notesManager.updateNoteLikes(noteId: note.id, isLiked: updatedNote.isLiked, likesCount: updatedNote.likesCount)
        }
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
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isSaved ? .yellow : .black)
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
            
            // Хэштеги
            if !note.hashtags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(zip(note.hashtags, hashtagColors)), id: \.0) { hashtag, color in
                            Text(hashtag)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(color)
                                .foregroundColor(textColor(for: color))
                                .cornerRadius(15)
                        }
                    }
                }
            }
            
            // Нижняя часть с кнопками
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        toggleLike()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundColor(isLiked ? .blue : .black)
                        Text("\(likesCount)")
                            .foregroundColor(.black)
                    }
                }
                
                Button(action: {
                    showComments = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.black)
                        Text("\(note.commentsCount)")
                            .foregroundColor(.black)
                    }
                }
                .sheet(isPresented: $showComments) {
                    CommentsView(note: note)
                }
                
                Spacer()
                
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
            savedNotes.removeAll(where: { $0.id == note.id })
        } else {
            var updatedNote = note
            updatedNote.isLiked = isLiked
            updatedNote.likesCount = likesCount
            savedNotes.append(updatedNote)
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

struct CommentsView: View {
    let note: Note
    @Environment(\.dismiss) private var dismiss
    @State private var newComment = ""
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    // Здесь будут комментарии
                    Text("Комментарии пока не реализованы")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                HStack {
                    TextField("Добавить комментарий...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        // Добавление комментария
                        dismiss()
                    }) {
                        Text("Отправить")
                            .foregroundColor(.blue)
                    }
                    .disabled(newComment.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Комментарии")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NoteCard(
        note: Note(
            author: "Макс Пупкин",
            date: Date(),
            title: "Конспекты по кмзи от Пупки Лупкиной",
            content: "Представляю вам свои гадкие конспекты по вышматы или не вышмату не знаб но не по кмзи точно",
            hashtags: ["#матан", "#крипта", "#бип"],
            likesCount: 1,
            commentsCount: 0
        ),
        savedNotes: .constant([]),
        notesManager: NotesManager()
    )
} 