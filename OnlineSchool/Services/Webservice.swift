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
    
    func getLessons(completion: @escaping ([Lesson]) -> ()) {
        guard let url = URL(string: "https://iphonephotographyschool.com/test-api/lessons") else {
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 60.0)
        
        if let data = URLCache.shared.cachedResponse(for: request)?.data {
            if let decoder = try? JSONDecoder().decode([String: [Lesson]].self, from: data) {
                let lessons : [Lesson] = decoder["lessons"] ?? []
                DispatchQueue.main.async {
                    completion(lessons)
                }
            } else {
                DispatchQueue.main.async {
                    completion([])
                }
            }
        } else {
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data,
                   let decoder = try? JSONDecoder().decode([String:[Lesson]].self, from: data)
                {
                    let lessons : [Lesson] = decoder["lessons"] ?? []
                    DispatchQueue.main.async {
                        completion(lessons)
                    }
                }else{
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            }).resume()
        }
    }
}
