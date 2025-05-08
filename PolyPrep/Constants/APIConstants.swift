import Foundation

enum APIConstants {
    static let baseURL = "YOUR_BACKEND_API_URL"
    
    enum Endpoints {
        static let login = "/auth/login"
        static let register = "/auth/register"
        static let userInfo = "/auth/user-info"
    }
}
