import SwiftUI

class NotesManager: ObservableObject {
    @Published var notes: [Note] = [
        Note(
            author: "Макс Пупкин",
            date: Date(),
            title: "Конспекты по кмзи от Пупки Лупкиной",
            content: "Представляю вам свои гадкие конспекты по вышматы или не вышмату не знаб но не по кмзи точно. Это очень длинный текст, который нужно сократить и показать троеточие в конце. Продолжение текста, которое будет скрыто до нажатия на троеточие.",
            hashtags: ["#матан", "#крипта", "#бип", "#программирование"],
            likesCount: 1,
            commentsCount: 0,
            comments: []
        ),
        Note(
            author: "Макс Пупкин",
            date: Date().addingTimeInterval(-86400),
            title: "Еще один конспект",
            content: "Другой интересный конспект по разным предметам",
            hashtags: ["#физика", "#математика", "#информатика"],
            likesCount: 5,
            commentsCount: 2,
            comments: [
                Comment(author: "Анна Сидорова", date: Date().addingTimeInterval(-10800), text: "Очень полезно!"),
                Comment(author: "Сергей Сергеев", date: Date().addingTimeInterval(-14400), text: "Спасибо!")
            ]
        )
    ]
    
    private var timer: Timer?
    
    init() {
        startScheduledNotesTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startScheduledNotesTimer() {
        // Проверяем отложенные заметки каждую минуту
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkScheduledNotes()
        }
    }
    
    private func checkScheduledNotes() {
        let now = Date()
        var updatedNotes = notes
        
        for (index, note) in notes.enumerated() {
            if note.isScheduled,
               let scheduledDate = note.scheduledDate,
               scheduledDate <= now {
                var updatedNote = note
                updatedNote.isScheduled = false
                updatedNote.isPrivate = false
                updatedNote.scheduledDate = nil
                updatedNotes[index] = updatedNote
            }
        }
        
        if updatedNotes != notes {
            DispatchQueue.main.async { [weak self] in
                self?.notes = updatedNotes
            }
        }
    }
    
    func addNote(_ note: Note) {
        // Все заметки добавляются в начало списка
        notes.insert(note, at: 0)
    }
    
    func getUserNotes(username: String) -> [Note] {
        notes.filter { $0.author == username }
    }
    
    func toggleLike(for noteId: UUID) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            notes[index].isLiked.toggle()
            notes[index].likesCount += notes[index].isLiked ? 1 : -1
        }
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        }
    }
    
    func updateNoteLikes(noteId: UUID, isLiked: Bool, likesCount: Int) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            notes[index].isLiked = isLiked
            notes[index].likesCount = likesCount
        }
    }
    
    func addComment(to noteId: UUID, comment: Comment) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            var updatedNote = notes[index]
            updatedNote.comments.insert(comment, at: 0)
            updatedNote.commentsCount += 1
            notes[index] = updatedNote
        }
    }
    
    func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            let kCount = Double(count) / 1000.0
            return String(format: "%.1fK", kCount)
        }
        return "\(count)"
    }
    
    func deleteNote(noteId: UUID) {
        notes.removeAll { $0.id == noteId }
    }
    
    func getScheduledNotes(username: String) -> [Note] {
        notes.filter { $0.author == username && $0.isScheduled }
    }
    
    func getActiveNotes(username: String) -> [Note] {
        notes.filter { $0.author == username && !$0.isScheduled }
    }
}
