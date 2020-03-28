//
//  Reducer.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/24/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation



func formatTime (time: Double) -> String? {
  let formatter = DateComponentsFormatter()
  formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
  formatter.allowedUnits = [ .hour, .minute, .second ] // Units to display in the formatted string
  formatter.zeroFormattingBehavior = [ .pad ] // Pad with zeroes where appropriate for the locale

  return  formatter.string(from: time)
}


struct UserData {
  var timerData : TimerData?
  var showFavoritesOnly = false
  var meditations : [Meditation]
  var newMeditation : Meditation? = nil
  var timedMeditation : Meditation? = nil

  
  struct TimerData {
    var endDate : Date
    var timeLeft : Double?
    var timeLeftLabel : String {

      return formatTime(time: self.timeLeft ?? 0.0) ?? "Empty"
    }
  }
}


enum AppAction {
  
  case scheduleNotification
  case notification(NotificationAction)
  
  enum NotificationAction{
    case willPresentNotification
    case didRecieveResponse
  }
  
  case putTimedMeditationOnDeck(Meditation)
  case takeTimedMeditationOffDeck

  
  case addButtonTapped
  case updateNewMeditation(Meditation)
  case addMeditationDismissed
  case deleteMeditationAt(IndexSet)
  case addMeditationWithDuration(Double)
  case startTimerPushed(startDate:Date, duration:Double, type:String)
  case timerFired
  case replaceOrAddMeditation( Meditation)
  case saveData
  
  case timerBottom(TimerBottomAction)
}

import SwiftUI

func appReducer( state: inout UserData, action: AppAction) -> [Effect<AppAction>] {
  switch action {
    
  case .scheduleNotification:
    let duration = state.timedMeditation!.duration
    return [Effect{ _ in
      NotificationHelper.singleton.scheduleNotification(notificationType: "Meditation Complete", seconds: duration)
      }]
    
  case .notification(.willPresentNotification):

    return [Effect{callback in
      callback(.takeTimedMeditationOffDeck)
      }]

  case .notification(.didRecieveResponse):
    return [Effect{callback in
      callback(.takeTimedMeditationOffDeck)
      }]
    
  case let .putTimedMeditationOnDeck(med):
    state.timedMeditation = med
    return []

    
  case .takeTimedMeditationOffDeck:
    let tempMed = state.timedMeditation!
    state.timedMeditation = nil
    return [Effect{callback in
      callback(.replaceOrAddMeditation(tempMed))
      }]
    
  case .addButtonTapped:
   let med = Meditation(id: UUID(),
    date: Date().description,
    duration: 300,
    hinderances: nil,
    factors: nil,
    entry: "",
    title: "Untitled")
   state.newMeditation = med
    return []

    
  case let .updateNewMeditation(updated):
    state.newMeditation = updated
    return []

  case .addMeditationDismissed:
    let transfer = state.newMeditation!
    state.newMeditation = nil
    return [Effect{ $0(.replaceOrAddMeditation(transfer))}]
    
  case let .deleteMeditationAt(indexSet):
    state.meditations.remove(atOffsets: indexSet)
    return []

  case let .startTimerPushed(startDate: date, duration:seconds, type: type):
    state.timerData = UserData.TimerData(endDate: date+seconds)
    return [
      Effect{$0(.timerFired)},
      Effect{$0(.putTimedMeditationOnDeck(
        Meditation(id: UUID(),
                   date: Date().description,
                   duration: seconds,
                   hinderances: nil,
                   factors: nil,
                   entry: "",
                   title: type
      )))},
      Effect{$0(.scheduleNotification)},
    ]
    
  case .timerFired:
    let currentDate = Date()
    guard
      let date = state.timerData?.endDate,
      currentDate < date,
      DateInterval(start: currentDate, end: date).duration >= 0 else {
        state.timerData = nil
        return []
    }
    
    let seconds = DateInterval(start: currentDate, end: date).duration
    state.timerData?.timeLeft = seconds
    
    return [Effect{callback in
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      callback(.timerFired)
       // Put any code you want to be delayed here
    }
    
    }]
  
    
    
    
    
    
  case let .addMeditationWithDuration(seconds):
    state.meditations.append(
      Meditation(id: UUID(),
                 date: Date().description,
                 duration: seconds,
                 hinderances: nil,
                 factors: nil,
                 entry: "",
                 title: "Untitled"
    ))
    return []
    
  case let .replaceOrAddMeditation(meditation):
    guard let index = (state.meditations.firstIndex { m in
      m.id == meditation.id
    }) else {
      state.meditations.append(meditation)
      return [Effect{ $0(.saveData) }]
    }
    
    state.meditations[index] = meditation
    return [Effect{ $0(.saveData) }]
    
  case .saveData:
    let meds = state.meditations
    
    return [Effect{_ in
      print("Saving")
      print(meds)

      Current.file.save(meds)
      print("Saved")
      print("Showing")

      print(Current.file.load())
      print("Showed")

      }]
    
  case .timerBottom(_):
    return []
  }
  
}
