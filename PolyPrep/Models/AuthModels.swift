import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let refresh_token: String
    let expires_in: Int
    let token_type: String
}

struct UserInfo: Codable {
    let id: String
    let username: String
    let email: String
    let name: String
    // Добавьте другие поля, которые приходят с вашего бэкенда
}

struct AuthError: Codable {
    let error: String
    let message: String
}
