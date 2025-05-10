import Foundation
import Combine

class SharedNotesManager: ObservableObject {
    static let shared = SharedNotesManager()
    private let userDefaults: UserDefaults?
    private var timer: Timer?
    @Published private(set) var notes: [Note] = []
    
    private init() {
        print("📱 App: Starting SharedNotesManager")
        let suiteName = "group.com.yourdomain.PolyPrep1"
        print("📱 App: UserDefaults suite name: \(suiteName)")
        
        // Проверяем доступность App Group
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) {
            print("📱 App: App Group container URL: \(containerURL)")
            
            // Проверяем права доступа к контейнеру
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: containerURL.path)
                print("📱 App: Container permissions: \(attributes[.posixPermissions] ?? "unknown")")
            } catch {
                print("❌ App: Failed to get container attributes: \(error)")
            }
        } else {
            print("❌ App: Failed to access App Group container")
        }
        
        userDefaults = UserDefaults(suiteName: suiteName)
        if let userDefaults = userDefaults {
            print("📱 App: UserDefaults initialized successfully")
            // Проверяем все ключи в UserDefaults
            let allKeys = userDefaults.dictionaryRepresentation().keys
            print("📱 App: Available UserDefaults keys: \(allKeys)")
            
            // Проверяем, есть ли уже сохраненные заметки
            if let data = userDefaults.data(forKey: "savedNotes") {
                print("📱 App: Found existing saved notes data")
                do {
                    let decoder = JSONDecoder()
                    let loadedNotes = try decoder.decode([Note].self, from: data)
                    print("📱 App: Successfully decoded \(loadedNotes.count) existing notes")
                } catch {
                    print("❌ App: Error decoding existing notes: \(error)")
                }
            } else {
                print("📱 App: No existing saved notes found")
            }
        } else {
            print("❌ App: Failed to initialize UserDefaults")
        }
        
        loadNotes()
        startUpdateTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startUpdateTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.saveNotes()
        }
    }
    
    private func loadNotes() {
        print("📱 App: Loading notes from UserDefaults")
        guard let userDefaults = userDefaults else {
            print("❌ App: UserDefaults is not initialized")
            return
        }
        
        if let data = userDefaults.data(forKey: "savedNotes") {
            do {
                let decoder = JSONDecoder()
                let loadedNotes = try decoder.decode([Note].self, from: data)
                DispatchQueue.main.async { [weak self] in
                    let previousCount = self?.notes.count ?? 0
                    self?.notes = loadedNotes
                    print("📱 App: Loaded \(loadedNotes.count) notes")
                    if previousCount != loadedNotes.count {
                        print("📱 App: Notes count changed \(previousCount) -> \(loadedNotes.count)")
                    }
                }
            } catch {
                print("❌ App: Error decoding notes: \(error)")
                print("❌ App: Raw data: \(String(data: data, encoding: .utf8) ?? "unable to convert to string")")
            }
        } else {
            print("📱 App: No saved notes found")
        }
    }
    
    private func saveNotes() {
        print("📱 App: Saving \(notes.count) notes to UserDefaults")
        guard let userDefaults = userDefaults else {
            print("❌ App: UserDefaults is not initialized")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(notes)
            print("📱 App: Encoded \(notes.count) notes, data size: \(data.count) bytes")
            
            userDefaults.set(data, forKey: "savedNotes")
            let success = userDefaults.synchronize()
            if success {
                print("📱 App: Successfully saved notes")
                
                // Проверяем, что данные действительно сохранились
                if let savedData = userDefaults.data(forKey: "savedNotes") {
                    print("📱 App: Verified saved data size: \(savedData.count) bytes")
                } else {
                    print("❌ App: Failed to verify saved data")
                }
            } else {
                print("❌ App: Failed to synchronize UserDefaults")
            }
        } catch {
            print("❌ App: Error saving notes: \(error)")
        }
    }
    
    func addNote(_ note: Note) {
        print("📱 App: Adding new note: \(note.title)")
        var currentNotes = notes
        currentNotes.insert(note, at: 0)
        notes = currentNotes
        saveNotes()
    }
    
    func deleteNote(_ note: Note) {
        print("📱 App: Deleting note: \(note.title)")
        var currentNotes = notes
        currentNotes.removeAll { $0.id == note.id }
        notes = currentNotes
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        print("📱 App: Updating note: \(note.title)")
        var currentNotes = notes
        if let index = currentNotes.firstIndex(where: { $0.id == note.id }) {
            currentNotes[index] = note
            notes = currentNotes
            saveNotes()
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
} 