import Foundation

struct Comment: Identifiable, Equatable {
    let id = UUID()
    let author: String
    let date: Date
    let text: String
    var isNew: Bool = false
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id &&
        lhs.author == rhs.author &&
        lhs.date == rhs.date &&
        lhs.text == rhs.text &&
        lhs.isNew == rhs.isNew
    }
}

struct Note: Identifiable, Equatable {
    let id = UUID()
    let author: String
    let date: Date
    let title: String
    let content: String
    let hashtags: [String]
    var likesCount: Int
    var commentsCount: Int
    var isLiked: Bool = false
    var isSaved: Bool = false
    var isPrivate: Bool = false
    var isScheduled: Bool = false
    var scheduledDate: Date?
    var comments: [Comment] = []
    var attachments: [Attachment] = []
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id &&
        lhs.author == rhs.author &&
        lhs.date == rhs.date &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.hashtags == rhs.hashtags &&
        lhs.likesCount == rhs.likesCount &&
        lhs.commentsCount == rhs.commentsCount &&
        lhs.isLiked == rhs.isLiked &&
        lhs.isSaved == rhs.isSaved &&
        lhs.isPrivate == rhs.isPrivate &&
        lhs.isScheduled == rhs.isScheduled &&
        lhs.scheduledDate == rhs.scheduledDate &&
        lhs.comments == rhs.comments &&
        lhs.attachments == rhs.attachments
    }
}
