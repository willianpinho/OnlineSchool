//
//  Webservice.swift
//  OnlineSchool
//
//  Created by Willian Junior Peres de Pinho on 14/02/23.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case badRequest
}
class Webservice {
    
    func getLessons() async throws -> [Lesson] {
        guard let url = URL(string: "https://iphonephotographyschool.com/test-api/lessons") else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.badRequest
        }
        
        let result = try JSONDecoder().decode(Lessons.self, from: data)
        return result.lessons
    }
}
