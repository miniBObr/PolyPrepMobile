import Foundation
import SwiftUI
import Combine

class NotesManager: ObservableObject {
    @Published var notes: [Note] = []
    private let sharedManager = SharedNotesManager.shared
    
    init() {
        // Подписываемся на изменения в SharedNotesManager
        sharedManager.$notes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedNotes in
                self?.notes = updatedNotes
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadNotes() {
        // Теперь просто обновляем локальное состояние
        notes = sharedManager.notes
    }
    
    func addNote(_ note: Note) {
        sharedManager.addNote(note)
    }
    
    func deleteNote(_ note: Note) {
        sharedManager.deleteNote(note)
    }
    
    func updateNote(_ note: Note) {
        sharedManager.updateNote(note)
    }
    
    func getUserNotes(username: String) -> [Note] {
        return notes.filter { $0.author == username }
    }
    
    func toggleLike(for noteId: UUID) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            var updatedNote = notes[index]
            updatedNote.isLiked.toggle()
            updatedNote.likesCount += updatedNote.isLiked ? 1 : -1
            updateNote(updatedNote)
        }
    }
    
    func updateNoteLikes(noteId: UUID, isLiked: Bool, likesCount: Int) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            var updatedNote = notes[index]
            updatedNote.isLiked = isLiked
            updatedNote.likesCount = likesCount
            updateNote(updatedNote)
        }
    }
    
    func addComment(to noteId: UUID, comment: Comment) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            var updatedNote = notes[index]
            updatedNote.comments.insert(comment, at: 0)
            updatedNote.commentsCount += 1
            updateNote(updatedNote)
        }
    }
    
    func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            let kCount = Double(count) / 1000.0
            return String(format: "%.1fK", kCount)
        }
        return "\(count)"
    }
    
    func getScheduledNotes(username: String) -> [Note] {
        notes.filter { $0.author == username && $0.isScheduled }
    }
    
    func getActiveNotes(username: String) -> [Note] {
        notes.filter { $0.author == username && !$0.isScheduled }
    }
}
 