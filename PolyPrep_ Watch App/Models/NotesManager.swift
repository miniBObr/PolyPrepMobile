import Foundation
import SwiftUI
import Combine

class NotesManager: ObservableObject {
    @Published var notes: [Note] = []
    private let userDefaults: UserDefaults?
    private var timer: Timer?
    
    init() {
        print("⌚️ Watch: Starting NotesManager")
        let suiteName = "group.com.yourdomain.PolyPrep1"
        print("⌚️ Watch: UserDefaults suite name: \(suiteName)")
        
        // Проверяем доступность App Group
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) {
            print("⌚️ Watch: App Group container URL: \(containerURL)")
        } else {
            print("❌ Watch: Failed to access App Group container")
        }
        
        userDefaults = UserDefaults(suiteName: suiteName)
        if let userDefaults = userDefaults {
            print("⌚️ Watch: UserDefaults initialized successfully")
            // Проверяем все ключи в UserDefaults
            let allKeys = userDefaults.dictionaryRepresentation().keys
            print("⌚️ Watch: Available UserDefaults keys: \(allKeys)")
        } else {
            print("❌ Watch: Failed to initialize UserDefaults")
        }
        
        loadNotes()
        startUpdateTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startUpdateTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.loadNotes()
        }
    }
    
    func loadNotes() {
        print("⌚️ Watch: Loading notes from UserDefaults")
        guard let userDefaults = userDefaults else {
            print("❌ Watch: UserDefaults is not initialized")
            return
        }
        
        if let data = userDefaults.data(forKey: "savedNotes") {
            do {
                let decoder = JSONDecoder()
                let loadedNotes = try decoder.decode([Note].self, from: data)
                DispatchQueue.main.async { [weak self] in
                    let previousCount = self?.notes.count ?? 0
                    self?.notes = loadedNotes
                    print("⌚️ Watch: Loaded \(loadedNotes.count) notes")
                    if previousCount != loadedNotes.count {
                        print("⌚️ Watch: Notes count changed \(previousCount) -> \(loadedNotes.count)")
                    }
                }
            } catch {
                print("❌ Watch: Error decoding notes: \(error)")
            }
        } else {
            print("⌚️ Watch: No saved notes found")
        }
    }
    
    func addNote(_ note: Note) {
        var currentNotes = notes
        currentNotes.insert(note, at: 0)
        notes = currentNotes
        saveNotes()
    }
    
    func deleteNote(_ note: Note) {
        var currentNotes = notes
        currentNotes.removeAll { $0.id == note.id }
        notes = currentNotes
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNotes = notes
            updatedNotes[index] = note
            notes = updatedNotes
            saveNotes()
        }
    }
    
    private func saveNotes() {
        print("⌚️ Watch: Saving \(notes.count) notes to UserDefaults")
        guard let userDefaults = userDefaults else {
            print("❌ Watch: UserDefaults is not initialized")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(notes)
            userDefaults.set(data, forKey: "savedNotes")
            let success = userDefaults.synchronize()
            if success {
                print("⌚️ Watch: Successfully saved notes")
            } else {
                print("❌ Watch: Failed to synchronize UserDefaults")
            }
        } catch {
            print("❌ Watch: Error saving notes: \(error)")
        }
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
        return notes.filter { $0.author == username && $0.isScheduled }
    }
    
    func getActiveNotes(username: String) -> [Note] {
        return notes.filter { $0.author == username && !$0.isScheduled }
    }
} 