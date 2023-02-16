//
//  LessonsView.swift
//  OnlineSchool
//
//  Created by Willian Junior Peres de Pinho on 14/02/23.
//

import SwiftUI
import CachedAsyncImage

struct LessonsView: View {
    
    @EnvironmentObject private var lessonsModel: LessonsModel
    @State var lessons: [Lesson] = []
    
    private func populateLessons()  {
        lessonsModel.populateLessons { lessons in
            self.lessons = lessons
        }
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(lessons.enumerated()), id: \.offset) { index, lesson in
                    NavigationLink(destination: LessonDetailViewControllerWrapper(id: index, lessons: lessons)) {
                        HStack {
                            CachedAsyncImage(url: lesson.thumbnail) { asyncImage in
                                asyncImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 70)
                                    .cornerRadius(4)
                            } placeholder: {
                                ProgressView()
                            }
                            .padding(.vertical, 4)
                            .frame(height: 70)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(lesson.name)
                                    .fontWeight(.regular)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                    }
                    
                }
            }.task {
                populateLessons()
            }
            .navigationTitle("Lessons")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView().environmentObject(LessonsModel(webservice: Webservice()))
    }
}
