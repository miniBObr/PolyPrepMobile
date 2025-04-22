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
            commentsCount: 0
        ),
        Note(
            author: "Макс Пупкин",
            date: Date().addingTimeInterval(-86400),
            title: "Еще один конспект",
            content: "Другой интересный конспект по разным предметам",
            hashtags: ["#физика", "#математика", "#информатика"],
            likesCount: 5,
            commentsCount: 2
        )
    ]
    
    func addNote(_ note: Note) {
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
} 