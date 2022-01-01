//
//  AppReducer.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 5/10/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import Foundation
import ComposableArchitecture


struct UserData : Equatable {
  var showFavoritesOnly = false

    var listViewState: ListViewState

  var newMeditation : Meditation? = nil

  var meditationTypeIndex : Int = 0
  var meditationTimeIndex : Int = 0
}

extension IdentifiedArray where Element == Meditation, ID == UUID {
  mutating func removeOrAdd(meditation : Meditation) {
    guard let index = (self.firstIndex{ $0.id == meditation.id }) else {
      self.insert(meditation, at: 0)
      return
    }
    self[index] = meditation
  }
}

func formatTime (time: Double) -> String? {
  let formatter = DateComponentsFormatter()
  formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
  formatter.allowedUnits = [ .hour, .minute, .second ] // Units to display in the formatted string
  formatter.zeroFormattingBehavior = [ .pad ] // Pad with zeroes where appropriate for the locale

  return  formatter.string(from: time)
}


func date(from string: String) -> Date? {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
  dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
  //let date = dateFormatter.date(from:isoDate)!
  
  
 // let dateFormatter = ISO8601DateFormatter()
  let date = dateFormatter.date(from:string)
  return date
}

func formattedDate(from date:Date) -> String {
  let dateFormatterPrint = DateFormatter()
  dateFormatterPrint.dateFormat = "EEEE, MMMM d, yyyy"
  return dateFormatterPrint.string(from: date)
}


/*
 
 Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
 09/12/2018                        --> MM/dd/yyyy
 09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
 Sep 12, 2:11 PM                   --> MMM d, h:mm a
 September 2018                    --> MMMM yyyy
 Sep 12, 2018                      --> MMM d, yyyy
 Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
 2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
 12.09.18                          --> dd.MM.yy
 10:41:02.112                      --> HH:mm:ss.SSS
 */


enum AppAction : Equatable {
  case listAction(ListAction)
  case notification(NotificationAction)
  
  enum NotificationAction{
    case willPresentNotification
    case didRecieveResponse
  }
  
  case updateNewMeditation(Meditation)
}

enum TimerBottomAction {
  case buttonPressed
}



struct AppEnvironment {
    var listEnv: ListEnv
}


let appReducer = Reducer<UserData, AppAction, AppEnvironment>.combine(
    listReducer.pullback(state: \.listViewState, action: /AppAction.listAction, environment: \AppEnvironment.listEnv),
Reducer{ state, action, environment in

  switch action {
 
//  case .meditationView(.timer(.timerFired)):
//      let tempMed = state.timedMeditation!
//      state.timedMeditation = nil
//      state.meditations.removeOrAdd(meditation: tempMed)
//
//      return .none
//
  case .notification(.willPresentNotification):
      state.listViewState.meditationView!.timedMeditation = nil
    return .none

  case .notification(.didRecieveResponse):
      state.listViewState.meditationView!.timedMeditation = nil
    return .none
   
  
    
  case let .updateNewMeditation(updated):
    state.newMeditation = updated
    return .none

  case .listAction(_):
      return .none
  }
}
)



