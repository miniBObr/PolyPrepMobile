//
//  ContentView.swift
//  PolyPrep
//
//  Created by boss on 25.03.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Основной контент
            TabView {
                // Browser Tab
                NavigationView {
                    ZStack {
                        Theme.background.edgesIgnoringSafeArea(.all)
                        Text("Browser Tab")
                            .foregroundColor(Theme.header)
                    }
                }
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Поиск")
                }
                
                // Bookmarks Tab
                NavigationView {
                    ZStack {
                        Theme.background.edgesIgnoringSafeArea(.all)
                        Text("Bookmarks Tab")
                            .foregroundColor(Theme.header)
                    }
                }
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Закладки")
                }
                
                // Profile Tab
                NavigationView {
                    ProfileView(authService: authService)
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
            }
            .accentColor(Theme.accent)
            .preferredColorScheme(.light)
            
            // Верхняя черная полоска с названием
            VStack(spacing: 0) {
                // Черная полоска
                Theme.header
                    .frame(height: 60)
                    .ignoresSafeArea(edges: .top)
                
                // Название приложения
                Text("PolyPrep <<")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.accent)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 40)
                    .background(Theme.header)
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onOpenURL { url in
            authService.handleAuthCallback(url: url)
        }
    }
}

struct ProfileView: View {
    @ObservedObject var authService: AuthService
    
    var body: some View {
        ZStack {
            Theme.background.edgesIgnoringSafeArea(.all)
            
            if authService.isLoggedIn {
                // Профиль пользователя
                VStack(spacing: 20) {
                    Text(authService.username ?? "User")
                        .font(.title)
                        .foregroundColor(Theme.header)
                    
                    // Здесь будет дополнительная информация о пользователе
                    Text("User Information")
                        .foregroundColor(Theme.header)
                    
                    Button(action: {
                        authService.logout()
                    }) {
                        Text("Выйти")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Theme.accent)
                            .cornerRadius(10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            } else {
                // Экран входа/регистрации
                VStack(spacing: 20) {
                    Button(action: {
                        authService.register()
                    }) {
                        Text("Регистрация")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Theme.accent)
                            .cornerRadius(10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Button(action: {
                        authService.login()
                    }) {
                        Text("Вход")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Theme.accent)
                            .cornerRadius(10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
