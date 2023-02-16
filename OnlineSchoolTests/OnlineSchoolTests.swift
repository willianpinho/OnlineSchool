//
//  OnlineSchoolTests.swift
//  OnlineSchoolTests
//
//  Created by Willian Junior Peres de Pinho on 14/02/23.
//

import XCTest
@testable import OnlineSchool

final class OnlineSchoolTests: XCTestCase {
    var networkManager: NetworkManager!
    
    func testLoadLessonsFromURL() async throws {
        let url = URL(string: "https://iphonephotographyschool.com/test-api/lessons")!
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            guard let httpResponse = response as? HTTPURLResponse else {
                XCTFail("Response is not of type HTTPURLResponse")
                return
            }
            XCTAssertEqual(httpResponse.statusCode, 200, "Expected a 200 OK response.")
            
            let decoder = JSONDecoder()
            let lessonResponse = try decoder.decode([String: [Lesson]].self, from: data)
            let lessons = lessonResponse["lessons"] ?? []
            XCTAssertEqual(lessons.count, 11, "Expected 11 lessons")
            
        } catch {
            XCTFail("Error occured during the request: \(error.localizedDescription)")
        }
    }
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.sharedInstance
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    func testIsReachable() {
        let expectation = self.expectation(description: "Is reachable expectation")
        NetworkManager.isReachable { (manager) in
            XCTAssertEqual(manager, self.networkManager)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testIsReachableViaWiFi() {
        let expectation = self.expectation(description: "Is reachable via WiFi expectation")
        NetworkManager.isReachableViaWiFi { (manager) in
            XCTAssertEqual(manager, self.networkManager)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

