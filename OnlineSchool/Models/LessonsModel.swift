//
//  LessonsModel.swift
//  OnlineSchool
//
//  Created by Willian Junior Peres de Pinho on 14/02/23.
//

import Foundation
import CoreData

@MainActor
class LessonsModel: NSObject, ObservableObject {
    let webservice: Webservice
    @Published var lessons: [Lesson] = []
    
    init(webservice: Webservice) {
        self.webservice = webservice
        super.init()
    }
        
    func populateLessons(completion: @escaping ([Lesson]) -> ()) {
        webservice.getLessons { lessons in
            completion(lessons)
        }
    }
}
