import Foundation

struct Note: Identifiable {
    let id: Int
    let author: String
    let date: Date
    let title: String
    let content: String
    var likesCount: Int
    var commentsCount: Int
    var HashTags: [String] = []
    var isSaved: Bool = false
    var like_id: Int
    
    func SetLike() {
        guard let url = URL(string: APIConstants.baseURL + "/like") else {
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
            "post_id": self.id
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
            
            let json = try! JSONSerialization.jsonObject(with: data!) as? [String: Any]
            
        }.resume()
        
    }
    
    func DelLike() {
        guard let url = URL(string: APIConstants.baseURL + "/like" + "?id=" + String(self.like_id)) else {
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
        request.httpMethod = "DELETE" // Можно изменить на POST/PUT и т.д.
        
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
