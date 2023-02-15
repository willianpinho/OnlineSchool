//
//  Lesson.swift
//  OnlineSchool
//
//  Created by Willian Junior Peres de Pinho on 14/02/23.
//

import Foundation

struct Lesson: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: URL
    let videoURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case thumbnail
        case videoURL = "video_url"
    }
}
