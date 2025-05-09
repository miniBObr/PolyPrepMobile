import Foundation

struct Comment: Identifiable, Equatable, Codable {
    let id: UUID
    let author: String
    let date: Date
    let text: String
    
    init(author: String, date: Date, text: String) {
        self.id = UUID()
        self.author = author
        self.date = date
        self.text = text
    }
}

struct Note: Identifiable, Equatable, Codable {
    let id: UUID
    let author: String
    let date: Date
    let title: String
    let content: String
    let hashtags: [String]
    var likesCount: Int
    var commentsCount: Int
    var isLiked: Bool
    var isSaved: Bool
    var isPrivate: Bool
    var isScheduled: Bool
    var scheduledDate: Date?
    var attachments: [Attachment]
    var comments: [Comment]
    
    init(author: String, date: Date, title: String, content: String, hashtags: [String], likesCount: Int = 0, commentsCount: Int = 0, isPrivate: Bool = false, isScheduled: Bool = false, scheduledDate: Date? = nil, attachments: [Attachment] = [], comments: [Comment] = []) {
        self.id = UUID()
        self.author = author
        self.date = date
        self.title = title
        self.content = content
        self.hashtags = hashtags
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLiked = false
        self.isSaved = false
        self.isPrivate = isPrivate
        self.isScheduled = isScheduled
        self.scheduledDate = scheduledDate
        self.attachments = attachments
        self.comments = comments
    }
} 