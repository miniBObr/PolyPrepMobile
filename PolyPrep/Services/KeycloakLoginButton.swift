//
//  KeycloakLoginButton.swift
//  PolyPrep
//
//  Created by Дмитрий Григорьев on 23.04.2025.
//


import SwiftUI
import AuthenticationServices
struct WebAuthenticationSessionExample: View {
    // Get an instance of WebAuthenticationSession using SwiftUI's
    // @Environment property wrapper.
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @State var responseText: String = ""
    
    var body: some View {
        Button("Sign in") {
            Task {
                do {
                    // Perform the authentication and await the result.
                    let urlWithToken = try await webAuthenticationSession.authenticate(
                        using: URL(string: "http://90.156.170.153:8091/realms/master/protocol/openid-connect/auth?client_id=polyclient&response_type=code&scope=openid%20profile&redirect_uri=yourapp://oauth-callback")!,
                        callbackURLScheme: "yourapp"
                    )
                    
                    let queryItems = URLComponents(string: urlWithToken.absoluteString)?.queryItems
                    let code = queryItems?.filter({ $0.name == "code" }).first?.value
                    print(queryItems)
                    print(code)
                    
                    guard let url = URL(string: "http://90.156.170.153:8081/api/v1/auth/callback?code=" + code! + "&next_page=yourapp://oauth-callback") else { return }
                    print(url.absoluteString)
                    URLSession.shared.dataTask(with: url) { data, _, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                responseText = "Ошибка: \(error.localizedDescription)"
                                return
                            }
                            responseText = String(data: data ?? Data(), encoding: .utf8) ?? "Нет данных"
                        }
                    }.resume()
                    // Call the method that completes the authentication using the
                    // returned URL.
//                    try await signIn(using: urlWithToken)
                    
                    print(responseText)
                } catch {
                    // Respond to any authorization errors.
                }
            }
        }
    }
}
