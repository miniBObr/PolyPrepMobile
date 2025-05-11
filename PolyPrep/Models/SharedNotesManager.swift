import Foundation
import Combine
import SwiftUI

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
    
    private func NetworkDelete(_ note: Note)
    {
        guard let url = URL(string: APIConstants.baseURL + "/post?id=" + String(note.id)) else {
            fatalError("Invalid URL")
        }
        
        print("Network delete post: ", url.absoluteString)
        var request = URLRequest(url: url)
        let accessToken = UserDefaults.standard.string(forKey: "access_token")
        
        request.setValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request){ data, response, error in
        
            guard let httpResponse = response as? HTTPURLResponse else {
                print( NSError(domain: "Invalid response", code: 0))
                return
            }
            print("Status code:", httpResponse.statusCode)
            print("Response:", String(data: data ?? Data(), encoding: .utf8) ?? "")
        }.resume()
    }
    
    func deleteNote(_ note: Note) {
        NetworkDelete(note)
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
    
    func toggleLike(for noteId: UInt) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            var updatedNote = notes[index]
            updatedNote.isLiked.toggle()
            updatedNote.likesCount += updatedNote.isLiked ? 1 : -1
            updateNote(updatedNote)
        }
    }
    
    func updateNoteLikes(noteId: UInt, isLiked: Bool, likesCount: Int) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            var updatedNote = notes[index]
            updatedNote.isLiked = isLiked
            updatedNote.likesCount = likesCount
            updateNote(updatedNote)
        }
    }
    
    func addComment(to noteId: UInt, comment: Comment) {
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
    
    func UploadNote(Note: Note) {
        guard let url = URL(string: APIConstants.baseURL + "/post") else {
            fatalError("Invalid URL")
        }
        
        // 2. Создаем URLRequest
        var request = URLRequest(url: url)
        let accessToken = UserDefaults.standard.string(forKey: "access_token")

        // 3. Добавляем заголовки
        request.setValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("YourApp/1.0", forHTTPHeaderField: "User-Agent")

        // 4. Настраиваем метод (GET по умолчанию)
        request.httpMethod = "POST" // Можно изменить на POST/PUT и т.д.
        let requestBody: [String: Any] = [
                "title": Note.title,
                "text": Note.content,
                "public": true,
                "hashtages": Note.hashtags,
                "scheduled_at": NSNull() // эквивалент null в JSON
            ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
                print("Failed to encode JSON")
                return
            }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request){ data, response, error in
        
            guard let httpResponse = response as? HTTPURLResponse else {
                print( NSError(domain: "Invalid response", code: 0))
                return
            }
            print("Status code:", httpResponse.statusCode)
            print("Response:", String(data: data ?? Data(), encoding: .utf8) ?? "")
        }.resume()
    }
    
    func getUsername(id: String) async -> String {
        guard let url = URL(string: APIConstants.baseURL + "/user" + "?id=" + id) else {
            fatalError("Invalid URL")
        }
        
        // 2. Создаем URLRequest
        var request = URLRequest(url: url)
        let accessToken = UserDefaults.standard.string(forKey: "access_token")

        // 3. Добавляем заголовки
        request.setValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("YourApp/1.0", forHTTPHeaderField: "User-Agent")

        // 4. Настраиваем метод (GET по умолчанию)
        request.httpMethod = "GET" // Можно изменить на POST/PUT и т.д.
        
        let (data, _) = try! await URLSession.shared.data(for: request)
            
            do {
                    // 1. Декодируем JSON в словарь
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    
                    // 2. Получаем значение по ключу
                    if let username = json?["username"] as? String {
                        return username
                    }
                    
                } catch {
                    print("🚨 JSON decoding error:", error.localizedDescription)
                }
        
        return "Неизвестный пользователь"
    }
    
    func getLikesCount(id: Int) async -> Int {
        guard let url = URL(string: APIConstants.baseURL + "/like" + "?id=" + String(id)) else {
            fatalError("Invalid URL")
        }
        
        // 2. Создаем URLRequest
        var request = URLRequest(url: url)
        let accessToken = UserDefaults.standard.string(forKey: "access_token")

        // 3. Добавляем заголовки
        request.setValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("YourApp/1.0", forHTTPHeaderField: "User-Agent")

        // 4. Настраиваем метод (GET по умолчанию)
        request.httpMethod = "GET" // Можно изменить на POST/PUT и т.д.
        
        let (data, _) = try! await URLSession.shared.data(for: request)
            
            do {
                    // 1. Декодируем JSON в словарь
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    
                    // 2. Получаем значение по ключу
                    if let count = json?["count"] as? Int {
                        print("Likes", count)
                        return count
                    }
                else
                {print("Can't get likes...")}
                    
                } catch {
                    print("🚨 JSON decoding error:", error.localizedDescription)
                }
        return 0
    }
    
    func fetchNotes() async
    {
        notes.removeAll()
        guard let url = URL(string: APIConstants.baseURL + "/post/random" + "?count=10") else {
            fatalError("Invalid URL")
        }
        
        // 2. Создаем URLRequest
        var request = URLRequest(url: url)

        // 3. Добавляем заголовки
        let accessToken = UserDefaults.standard.string(forKey: "access_token")
        request.setValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("YourApp/1.0", forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        
        let (data, _) = try! await URLSession.shared.data(for: request)
            
            
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    
                    if let posts = json?["posts"] as? [[String: Any]]
                    {
                        for post in posts {
                            addNote(
                                Note(
                                    id: post["id"] as! UInt,
                                    author: await getUsername(id: post["author_id"] as! String),
                                    date: Date(timeIntervalSince1970: post["updated_at"] as! TimeInterval),
                                    title: post["title"] as! String, content: post["text"] as! String,
                                    hashtags: post["hashtages"] as! [String],
                                    likesCount: 0,
                                    commentsCount: await getLikesCount(id: post["id"] as! Int)
//                                    like_id: -1
                                )
                            )
                            }
                    }
                    
                } catch {
                    print("🚨 JSON decoding error:", error.localizedDescription)
                }
    }
}
