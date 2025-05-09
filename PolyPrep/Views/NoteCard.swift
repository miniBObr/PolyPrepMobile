import SwiftUI
import AVFoundation

struct NoteCard: View {
    let note: Note
    @Binding var savedNotes: [Note]
    @ObservedObject var notesManager: SharedNotesManager
    let currentUsername: String
    
    @State private var isExpanded = false
    @State private var isLiked = false
    @State private var isSaved = false
    @State private var showDeleteAlert = false
    @State private var showComments = false
    @State private var textHeight: CGFloat = 0
    @State private var hashtagColors: [Color] = []
    
    init(note: Note, savedNotes: Binding<[Note]>, notesManager: SharedNotesManager, currentUsername: String) {
        self.note = note
        self._savedNotes = savedNotes
        self.notesManager = notesManager
        self.currentUsername = currentUsername
        _isLiked = State(initialValue: note.isLiked)
        _isSaved = State(initialValue: savedNotes.wrappedValue.contains { $0.id == note.id })
        _hashtagColors = State(initialValue: generateRandomColors(count: note.hashtags.count))
    }
    
    private func generateRandomColors(count: Int) -> [Color] {
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
    
    private func toggleLike() {
        isLiked.toggle()
        notesManager.updateNoteLikes(noteId: note.id, isLiked: isLiked, likesCount: note.likesCount + (isLiked ? 1 : -1))
    }
    
    private func toggleSaveNote() {
        isSaved.toggle()
        if isSaved {
            savedNotes.append(note)
        } else {
            savedNotes.removeAll { $0.id == note.id }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 8) {
                    if note.author == currentUsername {
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
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
            
            AuthorView(author: note.author)
            
            NoteContentView(
                content: note.content,
                textHeight: $textHeight,
                isExpanded: isExpanded,
                onTap: {
                    if textHeight > 60 || note.attachments.count > 2 {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                }
            )
            
            AttachmentsView(
                attachments: note.attachments,
                isExpanded: isExpanded
            )
            
            HashtagsView(
                hashtags: note.hashtags,
                hashtagColors: hashtagColors,
                textColor: textColor
            )
            
            ActionsView(
                note: note,
                isPrivate: note.isPrivate,
                isLiked: isLiked,
                likesCount: note.likesCount,
                commentsCount: note.commentsCount,
                notesManager: notesManager,
                currentUsername: currentUsername,
                savedNotes: $savedNotes,
                onLike: {
                    withAnimation {
                        toggleLike()
                    }
                },
                onShare: shareNote,
                showComments: $showComments
            )
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(note.isPrivate ? Color.black : Color.gray, lineWidth: note.isPrivate ? 2 : 1)
        )
        .padding(.horizontal)
        .alert("Удалить заметку?", isPresented: $showDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                notesManager.deleteNote(note)
                if isSaved {
                    savedNotes.removeAll { $0.id == note.id }
                }
            }
        } message: {
            Text("Это действие нельзя отменить")
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

private struct AuthorView: View {
    let author: String
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.black)
            Text(author)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

private struct NoteContentView: View {
    let content: String
    @Binding var textHeight: CGFloat
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(content + ((textHeight > 60) && !isExpanded ? "..." : ""))
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
    }
}

private struct AttachmentsView: View {
    let attachments: [Attachment]
    let isExpanded: Bool
    
    var body: some View {
        if !attachments.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Вложения")
                    .font(.headline)
                    .foregroundColor(.black)
                
                ForEach(Array(attachments.enumerated()), id: \.element.id) { index, attachment in
                    if isExpanded || index < 2 {
                        AttachmentView(attachment: attachment)
                            .opacity(isExpanded ? 1 : (index == 1 && attachments.count > 2 ? 0.5 : 1))
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

private struct HashtagsView: View {
    let hashtags: [String]
    let hashtagColors: [Color]
    let textColor: (Color) -> Color
    
    var body: some View {
        if !hashtags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(zip(hashtags, hashtagColors)), id: \.0) { hashtag, color in
                        Text(hashtag)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(color)
                            .foregroundColor(textColor(color))
                            .cornerRadius(15)
                    }
                }
            }
        }
    }
}

private struct ActionsView: View {
    let note: Note
    let isPrivate: Bool
    let isLiked: Bool
    let likesCount: Int
    let commentsCount: Int
    let notesManager: SharedNotesManager
    let currentUsername: String
    let savedNotes: Binding<[Note]>
    let onLike: () -> Void
    let onShare: () -> Void
    @Binding var showComments: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            if !isPrivate {
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundColor(isLiked ? .blue : .black)
                        Text(notesManager.formatCount(likesCount))
                            .foregroundColor(.black)
                    }
                }
                
                Button(action: { showComments = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.black)
                        Text(notesManager.formatCount(commentsCount))
                            .foregroundColor(.black)
                    }
                }
                .sheet(isPresented: $showComments) {
                    CommentsView(note: note, notesManager: notesManager, currentUsername: currentUsername, savedNotes: savedNotes)
                }
            }
            
            Spacer()
            
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.black)
            }
        }
    }
}

struct CommentsView: View {
    let note: Note
    @Environment(\.dismiss) private var dismiss
    @State private var newComment = ""
    @ObservedObject var notesManager: SharedNotesManager
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
    
    init(note: Note, notesManager: SharedNotesManager, currentUsername: String, savedNotes: Binding<[Note]>) {
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
                                text: newComment
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
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(comment.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Text(comment.text)
                .font(.body)
                .foregroundColor(.black)
        }
        .padding(.vertical, 4)
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
        notesManager: SharedNotesManager.shared,
        currentUsername: "Макс Пупкин"
    )
}
 