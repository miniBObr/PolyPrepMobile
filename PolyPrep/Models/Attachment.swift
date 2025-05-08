import Foundation

struct Attachment: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let fileType: String
    let fileData: Data
    let createdAt: Date
    
    init(id: UUID = UUID(), fileName: String, fileType: String, fileData: Data) {
        self.id = id
        self.fileName = fileName
        self.fileType = fileType
        self.fileData = fileData
        self.createdAt = Date()
    }
}

enum AttachmentType: String, Codable {
    case image
    case audio
    case document
    case other
} 