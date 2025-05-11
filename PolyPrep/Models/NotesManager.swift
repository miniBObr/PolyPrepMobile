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
    
    func getScheduledNotes(username: String) -> [Note] {
        notes.filter { $0.author == username && $0.isScheduled }
    }
    
    func getActiveNotes(username: String) -> [Note] {
        notes.filter { $0.author == username && !$0.isScheduled }
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
        
//        URLSession.shared.dataTask(with: request){ data, response, error in
//        
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print( NSError(domain: "Invalid response", code: 0))
//                return
//            }
//            print("Status code:", httpResponse.statusCode)
//            print("Response:", String(data: data ?? Data(), encoding: .utf8) ?? "")
//        }.resume()
        _ = HandleNetwork(request)
        showAlert(title: "Внимание", message: "Это тестовое сообщение")
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

