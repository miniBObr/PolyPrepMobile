import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var attachments: [String] = []
    @State private var hashtags = ""
    @State private var isPrivate = false
    @State private var isScheduled = false
    var onNoteCreated: (Note) -> Void
    var currentUsername: String
    
    private let maxLength = 150
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: true) {
                VStack(spacing: 16) {
                    // Заголовок
                    VStack(alignment: .leading) {
                        Text("Заголовок")
                            .font(.headline)
                            .foregroundColor(.black)
                        TextField("Конспекты по математике", text: $title)
                            .onChange(of: title) { newValue in
                                if newValue.count > maxLength {
                                    title = String(newValue.prefix(maxLength))
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    Text("\(title.count) / \(maxLength)")
                        .foregroundColor(title.count == maxLength ? .red : .gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)
                    
                    // Текст
                    VStack(alignment: .leading) {
                        Text("Текст")
                            .font(.headline)
                            .foregroundColor(.black)
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    // Вложения
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Вложения")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        ForEach(attachments, id: \.self) { attachment in
                            HStack {
                                Text(attachment)
                                    .foregroundColor(.black)
                                Spacer()
                                Button(action: {
                                    if let index = attachments.firstIndex(of: attachment) {
                                        attachments.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                        
                        Button(action: {
                            // Добавить вложение
                        }) {
                            Text("+ Добавить вложение")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Хэштеги
                    VStack(alignment: .leading) {
                        Text("Хэштеги")
                            .font(.headline)
                            .foregroundColor(.black)
                        TextField("#матан #крипта #хочу_зачет_по_бип", text: $hashtags)
                            .onChange(of: hashtags) { newValue in
                                if newValue.count > maxLength {
                                    hashtags = String(newValue.prefix(maxLength))
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    Text("\(hashtags.count) / \(maxLength)")
                        .foregroundColor(hashtags.count == maxLength ? .red : .gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)
                    
                    // Дополнительно
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Дополнительно")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Toggle(isOn: $isPrivate) {
                            Text("Сделать заметку приватной")
                                .foregroundColor(.black)
                        }
                        
                        Toggle(isOn: $isScheduled) {
                            Text("Отложенная отправка")
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Последний шаг
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Последний шаг")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Button(action: {
                            createAndSaveNote()
                        }) {
                            Text("Создать пост")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color.white)
            }
            .background(Theme.background)
            .navigationTitle("Новая заметка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
    
    private func createAndSaveNote() {
        let newNote = Note(
            author: currentUsername,
            date: Date(),
            title: title,
            content: content,
            likesCount: 0,
            commentsCount: 0
        )
        onNoteCreated(newNote)
        dismiss()
    }
} 
