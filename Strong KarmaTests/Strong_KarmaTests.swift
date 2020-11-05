//
//  Strong_KarmaTests.swift
//  Strong KarmaTests
//
//  Created by Justin Smith Nussli on 6/1/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import XCTest
import ComposableArchitecture

@testable import Strong_Karma

class Strong_KarmaTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      let testDate = dateFormatter.date(from:"1979/11/02 10:36:42 -0400")!
      
      let env = AppEnvironment(
         mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
         now: { testDate },
         uuid: { UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")! }
      )
      
      let store = TestStore(
      initialState: UserData(meditations: IdentifiedArray(FileIO().load()) ),
      reducer: appReducer,
      environment: env )
      
      store.assert(
         .send(.startTimerPushed(startDate: testDate, duration: 5, type: "No Self")) {
            $0.timerData = UserData.TimerData(endDate: Date(timeInterval: 5, since: testDate ), timeLeft: nil)
            
            $0.timedMeditation =  Meditation(id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")! ,
                                 date: env.now().description,
                                 duration: 5,
                                 hinderances: nil,
                                 factors: nil,
                                 entry: "",
                                 title: "No Self")
         }
            
         
      )
      
      
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
