import Foundation
import SwiftUI
import SafariServices
import WebKit

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .green // Цвет кнопок
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

class AuthService: ObservableObject {
    @Published var isLoggedIn = true
    @Published var username: String?
    @Published var error: String?
    @Published var userInfo: UserInfo?
    
    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "access_token") }
    }
    
    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "refresh_token") }
        set { UserDefaults.standard.set(newValue, forKey: "refresh_token") }
    }
    
    init() {
//        if let token = accessToken {
//            fetchUserInfo(token: token)
//        }
        self.accessToken = "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJXa3dyN0xpRTc3bUNBMDAteUJqb09WTFdEMjNOdjd2elNQSkNEVGp4WEtrIn0.eyJleHAiOjE3NDU0ODI0ODIsImlhdCI6MTc0NTQ0NzE1OSwiYXV0aF90aW1lIjoxNzQ1NDQ2NDgyLCJqdGkiOiIwNTYzMGExNi1kZWE5LTQyMTItODZkMC1mOGJmZWY1NzU5MjMiLCJpc3MiOiJodHRwOi8vOTAuMTU2LjE3MC4xNTM6ODA5MS9yZWFsbXMvbWFzdGVyIiwiYXVkIjpbIm1hc3Rlci1yZWFsbSIsImFjY291bnQiXSwic3ViIjoiNzc0ZWE2MDItYzVjNi00MjUxLWE5OTgtOThkYjZjYmNiODY0IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoicG9seWNsaWVudCIsInNlc3Npb25fc3RhdGUiOiI3MWJmMDMwMy1mYWJiLTRiODQtYmYwZC1hMmI1NDk0Y2VhZTciLCJhY3IiOiIwIiwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbImNyZWF0ZS1yZWFsbSIsImRlZmF1bHQtcm9sZXMtbWFzdGVyIiwib2ZmbGluZV9hY2Nlc3MiLCJhZG1pbiIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsibWFzdGVyLXJlYWxtIjp7InJvbGVzIjpbInZpZXctcmVhbG0iLCJ2aWV3LWlkZW50aXR5LXByb3ZpZGVycyIsIm1hbmFnZS1pZGVudGl0eS1wcm92aWRlcnMiLCJpbXBlcnNvbmF0aW9uIiwiY3JlYXRlLWNsaWVudCIsIm1hbmFnZS11c2VycyIsInF1ZXJ5LXJlYWxtcyIsInZpZXctYXV0aG9yaXphdGlvbiIsInF1ZXJ5LWNsaWVudHMiLCJxdWVyeS11c2VycyIsIm1hbmFnZS1ldmVudHMiLCJtYW5hZ2UtcmVhbG0iLCJ2aWV3LWV2ZW50cyIsInZpZXctdXNlcnMiLCJ2aWV3LWNsaWVudHMiLCJtYW5hZ2UtYXV0aG9yaXphdGlvbiIsIm1hbmFnZS1jbGllbnRzIiwicXVlcnktZ3JvdXBzIl19LCJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwic2lkIjoiNzFiZjAzMDMtZmFiYi00Yjg0LWJmMGQtYTJiNTQ5NGNlYWU3IiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJEaW1rYSBUdXpvdiIsInByZWZlcnJlZF91c2VybmFtZSI6ImthYjE2MzRAeWEucnUiLCJnaXZlbl9uYW1lIjoiRGlta2EiLCJmYW1pbHlfbmFtZSI6IlR1em92IiwiZW1haWwiOiJrYWIxNjM0QHlhLnJ1In0.ghDygepTFfF7RVlYVWLuiQ3Y5refC6KKEyDQLDbgyXzW_-VWk_65Zc4faB0U7eP-VQvWUPNff_s9FTadCbsLBk5rWZ4qcjcib9-FSqGqTlAKJuCV8f-uqfX8RaHQwjtm6KrKz_9BoCOBQltmCmpJmot1AVpj16_jAw45O-_DUa918o2-lrNq5F_NFcQMoLK1EJCEhIMKr7T7QX8H6n419lG5RnblIFl1zUVCcM7b4y_PydS98mv55KGD9I1Xk8LY7aRVNgLB_aM9Bl4XCu9vffbe_d3BcpgC7CePPX6xZsLsk9WhyuIpAZlB6-LYht4h3aPFlLJl0t-g7Lot0awyHg"
        
//        userData()
    }
    
    func handleAuthCallback(url: URL) {
        guard let code = extractCode(from: url) else {
            self.error = "Не удалось получить код авторизации"
            return
        }
        
        exchangeCodeForToken(code: code)
    }
    
    private func extractCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return nil
        }
        return code
    }
    
    private func exchangeCodeForToken(code: String) {
        guard let url = URL(string: APIConstants.baseURL + APIConstants.AuthEndpoints.login) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["code": code]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                DispatchQueue.main.async {
                    self.accessToken = authResponse.access_token
                    self.refreshToken = authResponse.refresh_token
                    self.isLoggedIn = true
                    self.fetchUserInfo(token: authResponse.access_token)
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                }
            }
        }.resume()
    }
    
    private func fetchUserInfo(token: String) {
        guard let url = URL(string: APIConstants.baseURL + APIConstants.AuthEndpoints.userInfo) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
                DispatchQueue.main.async {
                    self.userInfo = userInfo
                    self.username = userInfo.username
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                }
            }
        }.resume()
    }
    
    func logout() {
        accessToken = nil
        refreshToken = nil
        userInfo = nil
        username = nil
        isLoggedIn = false
    }
    
    func login() {
        // Открываем URL для авторизации через ваш бэкенд
        if let url = URL(string: APIConstants.baseURL + APIConstants.AuthEndpoints.login) {
            UIApplication.shared.open(url)
        }
    }
    
    func register() {
        // Открываем URL для регистрации через ваш бэкенд
//        if let url = URL(string: APIConstants.baseURL + APIConstants.AuthEndpoints.register) {
//            UIApplication.shared.open(url)
//        }
//        SafariView(url: URL(string: APIConstants.baseURL + APIConstants.AuthEndpoints.register)!)
    }
    
    func userData(auth authService: AuthService)
    {
        // 1. Создаем URL
        guard let url = URL(string: APIConstants.baseURL + "/user" + "?id=774ea602-c5c6-4251-a998-98db6cbcb864") else {
            fatalError("Invalid URL")
        }
        
        // 2. Создаем URLRequest
        var request = URLRequest(url: url)

        // 3. Добавляем заголовки
        request.setValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("YourApp/1.0", forHTTPHeaderField: "User-Agent")

        // 4. Настраиваем метод (GET по умолчанию)
        request.httpMethod = "GET" // Можно изменить на POST/PUT и т.д.

        // 2. Создаем и запускаем запрос
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code:", httpResponse.statusCode)
                print("Response Headers:", httpResponse.allHeaderFields)
//                print("username", httpResponse.(forKey: "username") ?? "")
            }
            
            if let data = data {
                do {
                        // 1. Декодируем JSON в словарь
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        
                        // 2. Получаем значение по ключу
                        if let username = json?["username"] as? String {
                            print("✅ Username:", username)
                            authService.username = username
                        } else {
                            print("⚠️ 'username' not found or invalid type")
                        }
                        
                    } catch {
                        print("🚨 JSON decoding error:", error.localizedDescription)
                    }
            }
        }.resume()
    }
}
