import SwiftUI

class NotesManager: ObservableObject {
    @Published var notes: [Note] = [
//        Note(
//            author: "Макс Пупкин",
//            date: Date(),
//            title: "Конспекты по кмзи от Пупки Лупкиной",
//            content: "22222222Представляю вам свои гадкие конспекты по вышматы или не вышмату не знаб но не по кмзи точно. Это очень длинный текст, который нужно сократить и показать троеточие в конце. Продолжение текста, которое будет скрыто до нажатия на троеточие.",
//            likesCount: 1,
//            commentsCount: 0
//        ),
//        Note(
//            author: "Макс Пупкин",
//            date: Date().addingTimeInterval(-86400),
//            title: "Еще один конспект",
//            content: "Другой интересный конспект по разным предметам",
//            likesCount: 5,
//            commentsCount: 2
//        )
    ]
    
    func addNote(_ note: Note) {
        notes.insert(note, at: 0)
    }
    
    func getUserNotes(username: String) -> [Note] {
        notes.filter { $0.author == username }
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
                                    id: post["id"] as! Int,
                                    author: try await getUsername(id: post["author_id"] as! String),
                                    date: Date(timeIntervalSince1970: post["updated_at"] as! TimeInterval),
                                    title: post["title"] as! String, content: post["text"] as! String,
                                    likesCount: try await getLikesCount(id: post["id"] as! Int),
                                    commentsCount: 0,
                                    HashTags: post["hashtages"] as! [String],
                                    like_id: -1
                                )
                            )
                            }
                    }
                    
                } catch {
                    print("🚨 JSON decoding error:", error.localizedDescription)
                }
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
                "hashtages": Note.HashTags,
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
    
}
