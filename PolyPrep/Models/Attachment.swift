import Foundation

struct Attachment: Identifiable, Equatable, Codable {
    let id: UUID
    let fileName: String
    let fileType: String
    let fileData: Data
    
    init(fileName: String, fileType: String, fileData: Data) {
        self.id = UUID()
        self.fileName = fileName
        self.fileType = fileType
        self.fileData = fileData
    }
    
    static func == (lhs: Attachment, rhs: Attachment) -> Bool {
        lhs.id == rhs.id &&
        lhs.fileName == rhs.fileName &&
        lhs.fileType == rhs.fileType &&
        lhs.fileData == rhs.fileData
    }
}

enum AttachmentType: String, Codable {
    case image
    case audio
    case document
    case other
}
