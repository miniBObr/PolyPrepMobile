import SwiftUI
import AuthenticationServices

struct KeycloakLoginButton: View {
    // Keycloak OAuth2 параметры (замените на свои)
    private let authURL = URL(string: "https://your-keycloak-server/auth/realms/REALM_NAME/protocol/openid-connect/auth?client_id=YOUR_CLIENT_ID&redirect_uri=yourapp://oauth-callback&response_type=code")!
    private let callbackURLScheme = "yourapp" // Должен совпадать с CFBundleURLSchemes
    
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    
    var body: some View {
        Button(action: startKeycloakLogin) {
            HStack {
                Image(systemName: "person.fill")
                Text("Войти через Keycloak")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .disabled(isAuthenticating)
        .alert("Ошибка", isPresented: .constant(errorMessage != nil)) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func startKeycloakLogin() {
        isAuthenticating = true
        errorMessage = nil
        
        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: callbackURLScheme
        ) { callbackURL, error in
            isAuthenticating = false
            
            // Обработка ответа
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            guard let callbackURL = callbackURL else {
                errorMessage = "Не получен callback URL"
                return
            }
            
            // Извлекаем authorization code из URL (например: yourapp://oauth-callback?code=ABC123)
            guard let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "code" })?
                .value else {
                errorMessage = "Authorization code не найден"
                return
            }
            
            print("Успешно! Authorization code: \(code)")
            // Здесь обменяйте code на токен (POST запрос к /token endpoint Keycloak)
            exchangeCodeForToken(code: code)
        }
        
        // Настройки сессии
        session.presentationContextProvider = contextProvider
        session.prefersEphemeralWebBrowserSession = true // Не сохранять куки
        session.start()
    }
    
    private func exchangeCodeForToken(code: String) {
        // Пример запроса для обмена code на токен
        let tokenURL = URL(string: "https://your-keycloak-server/auth/realms/REALM_NAME/protocol/openid-connect/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET&grant_type=authorization_code&code=\(code)&redirect_uri=yourapp://oauth-callback"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Ошибка запроса токена: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "Нет данных в ответе"
                }
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(KeycloakTokenResponse.self, from: data)
                print("Токен получен: \(tokenResponse.accessToken)")
                // Сохраните токен в Keychain/SecureStorage
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Ошибка парсинга токена: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private var contextProvider: AuthContextProvider {
        AuthContextProvider()
    }
}

// Модель для ответа Keycloak /token endpoint
struct KeycloakTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

// Для показа окна авторизации
class AuthContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: { $0.isKeyWindow }) ?? UIWindow()
    }
}