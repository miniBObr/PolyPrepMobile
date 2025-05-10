import SwiftUI

@main
struct PolyPrep_Watch_AppApp: App {
    @StateObject private var notesManager = NotesManager()
    
    var body: some Scene {
        WindowGroup {
            SavedNotesView()
                .environmentObject(notesManager)
        }
    }
}

struct SavedNotesView: View {
    @EnvironmentObject var notesManager: NotesManager
    
    var savedNotes: [Note] {
        notesManager.notes.filter { $0.isSaved }
    }
    
    var body: some View {
        if savedNotes.isEmpty {
            VStack {
                Text("Нет сохраненных заметок")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        } else {
            List {
                ForEach(savedNotes) { note in
                    NoteRow(note: note)
                }
            }
            .navigationTitle("Сохраненные")
        }
    }
}

struct NoteRow: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(note.content)
                .font(.caption)
                .lineLimit(2)
                .foregroundColor(.gray)
            
            HStack {
                Text(note.author)
                    .font(.caption2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(note.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
