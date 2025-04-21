import Foundation
import SwiftUI

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
        if let token = accessToken {
            fetchUserInfo(token: token)
        }
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
        guard let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.login) else { return }
        
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
        guard let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.userInfo) else { return }
        
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
        if let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.login) {
            UIApplication.shared.open(url)
        }
    }
    
    func register() {
        // Открываем URL для регистрации через ваш бэкенд
        if let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.register) {
            UIApplication.shared.open(url)
        }
    }
} 
