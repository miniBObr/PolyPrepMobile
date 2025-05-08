import SwiftUI
import AVFoundation

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
    
    private var commentsCount: Int {
        if let savedNote = savedNotes.first(where: { $0.id == note.id }) {
            return savedNote.commentsCount
        }
        return note.commentsCount
    }
    
    private var comments: [Comment] {
        if let savedNote = savedNotes.first(where: { $0.id == note.id }) {
            return savedNote.comments
        }
        return note.comments
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
    
    private func toggleSaveNote() {
        if isSaved {
            savedNotes.removeAll(where: { $0.id == note.id })
        } else {
            var updatedNote = note
            updatedNote.isLiked = isLiked
            updatedNote.likesCount = likesCount
            updatedNote.comments = comments
            updatedNote.commentsCount = commentsCount
            savedNotes.append(updatedNote)
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
                if textHeight > 60 || note.attachments.count > 2 {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }) {
                Text(note.content + ((textHeight > 60 || note.attachments.count > 2) && !isExpanded ? "..." : ""))
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
            
            // Вложения
            if !note.attachments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Вложения")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    ForEach(Array(note.attachments.enumerated()), id: \.element.id) { index, attachment in
                        if isExpanded || index < 2 {
                            AttachmentView(attachment: attachment)
                                .opacity(isExpanded ? 1 : (index == 1 && note.attachments.count > 2 ? 0.5 : 1))
                        }
                    }
                }
                .padding(.top, 8)
            }
            
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
                        Text(notesManager.formatCount(likesCount))
                            .foregroundColor(.black)
                    }
                }
                
                Button(action: {
                    showComments = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.black)
                        Text(notesManager.formatCount(commentsCount))
                            .foregroundColor(.black)
                    }
                }
                .sheet(isPresented: $showComments) {
                    CommentsView(note: note, notesManager: notesManager, currentUsername: "Макс Пупкин", savedNotes: $savedNotes)
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
    @ObservedObject var notesManager: NotesManager
    @State private var currentUsername: String
    @Binding var savedNotes: [Note]
    
    private var currentComments: [Comment] {
        if let savedNote = savedNotes.first(where: { $0.id == note.id }) {
            return savedNote.comments
        }
        return note.comments
    }
    
    private var currentCommentsCount: Int {
        if let savedNote = savedNotes.first(where: { $0.id == note.id }) {
            return savedNote.commentsCount
        }
        return note.commentsCount
    }
    
    init(note: Note, notesManager: NotesManager, currentUsername: String, savedNotes: Binding<[Note]>) {
        self.note = note
        self.notesManager = notesManager
        self._currentUsername = State(initialValue: currentUsername)
        self._savedNotes = savedNotes
    }
    
    private func updateSavedNote(with comment: Comment) {
        if let index = savedNotes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = savedNotes[index]
            updatedNote.comments.insert(comment, at: 0)
            updatedNote.commentsCount += 1
            savedNotes[index] = updatedNote
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if currentComments.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Text("Прокомментируй первый!")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(currentComments) { comment in
                                CommentView(comment: comment)
                            }
                        }
                        .padding()
                    }
                }
                
                HStack {
                    TextField("Добавить комментарий...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        if !newComment.isEmpty {
                            let comment = Comment(
                                author: currentUsername,
                                date: Date(),
                                text: newComment,
                                isNew: true
                            )
                            notesManager.addComment(to: note.id, comment: comment)
                            updateSavedNote(with: comment)
                            newComment = ""
                        }
                    }) {
                        Text("Отправить")
                            .foregroundColor(.blue)
                    }
                    .disabled(newComment.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Комментарии (\(notesManager.formatCount(currentCommentsCount)))")
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

struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.author)
                    .font(.headline)
                Spacer()
                Text(comment.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(comment.text)
                .font(.body)
        }
        .padding()
        .background(comment.isNew ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AttachmentView: View {
    let attachment: Attachment
    @State private var showPreview = false
    
    var body: some View {
        Button(action: {
            showPreview = true
        }) {
            HStack {
                Image(systemName: attachmentIcon(for: attachment.fileType))
                    .foregroundColor(.black)
                Text(attachment.fileName)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .sheet(isPresented: $showPreview) {
            AttachmentPreviewView(attachment: attachment)
        }
    }
    
    private func attachmentIcon(for fileType: String) -> String {
        switch fileType.lowercased() {
        case "image/jpeg", "image/png", "image/gif":
            return "photo"
        case "audio/mpeg", "audio/wav":
            return "music.note"
        case "application/pdf":
            return "doc.text"
        default:
            return "doc"
        }
    }
}

struct AttachmentPreviewView: View {
    let attachment: Attachment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if attachment.fileType.lowercased().contains("image") {
                    if let image = UIImage(data: attachment.fileData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                } else if attachment.fileType.lowercased().contains("audio") {
                    AudioPlayerView(data: attachment.fileData)
                } else {
                    Text("Предпросмотр недоступен")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle(attachment.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AudioPlayerView: View {
    let data: Data
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack {
            Button(action: {
                if isPlaying {
                    audioPlayer?.pause()
                } else {
                    if audioPlayer == nil {
                        do {
                            audioPlayer = try AVAudioPlayer(data: data)
                            audioPlayer?.prepareToPlay()
                        } catch {
                            print("Error creating audio player: \(error)")
                        }
                    }
                    audioPlayer?.play()
                }
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.black)
            }
        }
        .onDisappear {
            audioPlayer?.stop()
            audioPlayer = nil
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