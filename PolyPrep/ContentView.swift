//
//  ContentView.swift
//  PolyPrep
//
//  Created by boss on 25.03.2025.
//

import SwiftUI
import AuthenticationServices

// Тестовые данные
//private var allNotes = [
//    Note(
//        author: "Макс Пупкин",
//        date: Date(),
//        title: "Конспекты по кмзи от Пупки Лупкиной",
//        content: "11111111Представляю вам свои гадкие конспекты по вышматы или не вышмату не знаб но не по кмзи точно. Это очень длинный текст, который нужно сократить и показать троеточие в конце. Продолжение текста, которое будет скрыто до нажатия на троеточие.",
//        likesCount: 1,
//        commentsCount: 0
//    ),
//    Note(
//        author: "Макс Пупкин",
//        date: Date().addingTimeInterval(-86400),
//        title: "Еще один конспект",
//        content: "Другой интересный конспект по разным предметам",
//        likesCount: 5,
//        commentsCount: 2
//    )
//]

struct ContentView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var notesManager = NotesManager()
    @State private var savedNotes: [Note] = []
    @State private var selectedTab = 0
    @State private var showNewNote = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Основной контент
            TabView(selection: $selectedTab) {
                // Browser Tab
                NavigationView {
                    ZStack {
                        Theme.background.edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 0) {
                            // Список заметок
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(notesManager.notes) { note in
                                        NoteCard(note: note, savedNotes: $savedNotes)
                                            .contentShape(Rectangle())
                                    }
                                }
                                .padding(.top, 62)
                                .padding(.bottom, 16)
                            }
                            .scrollDismissesKeyboard(.immediately)
                            
                            // Кнопки внизу
                            HStack(spacing: 20) {
                                // Кнопка поиска
                                Button(action: {
                                    // Действие для поиска
                                    Task {
                                        await notesManager.fetchNotes()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.black)
                                        Text("Поиск")
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                }
                                
                                // Кнопка новой заметки
                                Button(action: {
                                    if authService.isLoggedIn {
                                        showNewNote = true
                                    } else {
                                        selectedTab = 2
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                            .foregroundColor(.black)
                                        Text("Новая заметка")
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                .sheet(isPresented: $showNewNote) {
                    NewNoteView(onNoteCreated: { newNote in
                        notesManager.addNote(newNote)
                        notesManager.UploadNote(Note: newNote)
                    }, currentUsername: authService.username ?? "Неизвестный пользователь")
                }
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Поиск")
                }
                .tag(0)
                
                // Bookmarks Tab
                NavigationView {
                    ZStack {
                        Theme.background.edgesIgnoringSafeArea(.all)
                        
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(savedNotes) { note in
                                    NoteCard(note: note, savedNotes: $savedNotes)
                                        .contentShape(Rectangle())
                                }
                            }
                            .padding(.top, 62)
                            .padding(.bottom, 16)
                        }
                        .scrollDismissesKeyboard(.immediately)
                    }
                }
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Закладки")
                }
                .tag(1)
                
                // Profile Tab
                NavigationView {
                    ProfileView(authService: authService, notesManager: notesManager)
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
                .tag(2)
            }
            .accentColor(Theme.accent)
            
            // Верхняя черная полоска с названием
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Theme.header)
                    .frame(height: 60)
                    .ignoresSafeArea(edges: .top)
                
                Text("PolyPrep <<")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.accent)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 40)
                    .background(Theme.header)
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
    @ObservedObject var notesManager: NotesManager
    @State private var showSafari = false
    @State private var startingWebAuthenticationSession = false
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    
    var userNotes: [Note] {
        notesManager.getUserNotes(username: authService.username ?? "")
    }
    
    var body: some View {
        ZStack {
            Theme.background.edgesIgnoringSafeArea(.all)
            
            if authService.isLoggedIn {
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 20) {
                            Button(action: {
                                authService.userData(auth: authService)
                            }) {
                                Text("Refresh")
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(Theme.accent)
                                    .cornerRadius(10)
                            }
                            Text(authService.username ?? "User")
                                .font(.title)
                                .foregroundColor(Theme.header)
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
                        .padding(.top, 60)
                        
                        // Заметки пользователя
                        if !userNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Мои заметки")
                                    .font(.title2)
                                    .foregroundColor(Theme.header)
                                    .padding(.horizontal)
                                
                                ForEach(userNotes) { note in
                                    NoteCard(note: note, savedNotes: .constant([]))
                                }
                            }
                            .padding(.top, 32)
                        }
                    }
                    .padding()
                }
            } else {
                // Экран входа/регистрации
                VStack(spacing: 20) {
                    WebAuthenticationSessionExample()
                    NavigationLink(destination: SettingsView()) {
                        Text("Настройки")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Theme.accent)
                            .cornerRadius(10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    Button(action: {
//                        authService.register()
//                        showSafari = true
                    }) {
                        Text("Регистрация")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Theme.accent)
                            .cornerRadius(10)
                    }
                    .buttonStyle(ScaleButtonStyle())
//                    .sheet(isPresented: $showSafari) {
//                        WebViewWithPost(
//                            url: URL(string: APIConstants.baseURL + APIConstants.AuthEndpoints.check)!,
//                                        postData: ["refresh_token": "null", "access_token": "null", "next_page": "user"]
//                                    )
//                    }
                    
                    Button(action: {
//                        authService.login()
//                        showSafari = true
                        self.startingWebAuthenticationSession = true
                    }) {
                        Text("Вход")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Theme.accent)
                            .cornerRadius(10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .sheet(isPresented: $showSafari) {
                        SafariView(url: URL(string: "http://90.156.170.153:8091/realms/master/protocol/openid-connect/auth?client_id=polyclient&response_type=code&scope=openid%20profile&redirect_uri=http://90.156.170.153:3001/user")!)
                    }
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
