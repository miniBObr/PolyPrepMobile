import Foundation

struct Note: Identifiable {
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
} 