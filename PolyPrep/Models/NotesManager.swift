import SwiftUI

class NotesManager: ObservableObject {
    @Published var notes: [Note] = [
        Note(
            author: "Макс Пупкин",
            date: Date(),
            title: "Конспекты по кмзи от Пупки Лупкиной",
            content: "Представляю вам свои гадкие конспекты по вышматы или не вышмату не знаб но не по кмзи точно. Это очень длинный текст, который нужно сократить и показать троеточие в конце. Продолжение текста, которое будет скрыто до нажатия на троеточие.",
            likesCount: 1,
            commentsCount: 0
        ),
        Note(
            author: "Макс Пупкин",
            date: Date().addingTimeInterval(-86400),
            title: "Еще один конспект",
            content: "Другой интересный конспект по разным предметам",
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
} 