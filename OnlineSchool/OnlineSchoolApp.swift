//
//  OnlineSchoolApp.swift
//  OnlineSchool
//
//  Created by Willian Junior Peres de Pinho on 14/02/23.
//

import SwiftUI

@main
struct OnlineSchoolApp: App {
    
    @StateObject private var lessonsModel = LessonsModel(webservice: Webservice())
    
    var body: some Scene {
        WindowGroup {
            LessonsView().environmentObject(lessonsModel)
        }
    }
}
