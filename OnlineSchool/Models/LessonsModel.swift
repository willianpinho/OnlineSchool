//
//  LessonsModel.swift
//  OnlineSchool
//
//  Created by Willian Junior Peres de Pinho on 14/02/23.
//

import Foundation

@MainActor
class LessonsModel: ObservableObject {
    let webservice: Webservice
    @Published var lessons: [Lesson] = []
    
    init(webservice: Webservice) {
        self.webservice = webservice
    }
    
    func populateLessons() async throws {
        lessons = try await webservice.getLessons()
    }
}
