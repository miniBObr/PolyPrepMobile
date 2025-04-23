import Foundation

enum APIConstants {
    static var baseURL = UserDefaults.standard.string(forKey: "BackEndURL") ?? "http://90.156.170.153:8081/api/v1";
    static var KeyCloakURL = UserDefaults.standard.string(forKey: "KeyCloakURL") ?? "http://90.156.170.153:8091";
    
    enum AuthEndpoints {
        static let login = "/auth/login"
        static let register = "/auth/register"
        static let userInfo = "/auth/user-info"
        static let check = "/auth/check"
        static let logout = "/auth/logout"
        static let callback = "auth/callback"
        static let refresh = "auth/refresh"
    }
} 
