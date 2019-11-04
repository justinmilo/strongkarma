//
//  Reducer.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/24/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation

final class NotificationPlace : NSObject, UNUserNotificationCenterDelegate {
  override init() {
    
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    notificationCenter.requestAuthorization(options: options) {
        (didAllow, error) in
        if !didAllow {
            print("User has declined notifications")
        }
    }
    
    notificationCenter.getNotificationSettings { (settings) in
      if settings.authorizationStatus != .authorized {
        print("notifications are not authroized")
      }
      else {
        print("notifications are!! authorized")

      }
    }
    super.init()
    
    notificationCenter.delegate = self
  }
  
  let notificationCenter = UNUserNotificationCenter.current()
  var completion: ()->() = { }
   
  func scheduleNotification(notificationType: String, seconds: TimeInterval, completion: @escaping ()->() ) {
     print ("got Here")
    
    self.completion = completion
    
     let content = UNMutableNotificationContent()
     let userActions = "User Actions"
     
     content.title = notificationType
     content.body = "This is example how to create " + notificationType
     content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell.caf"))
     content.badge = 1
     content.categoryIdentifier = userActions
     
     let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
     let identifier = "Local Notification"
     let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
     
     notificationCenter.add(request) { (error) in
       if let error = error {
         print("Error \(error.localizedDescription)")
       }
     }
     
     let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
     let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
     let category = UNNotificationCategory(identifier: userActions, actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
     
     notificationCenter.setNotificationCategories([category])
   }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    print ("userNotificationHere")
    self.completion()
    }
   
   func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
   
   }
   
   func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {


   }
}


func formatTime (time: Double) -> String? {
  let formatter = DateComponentsFormatter()
  formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
  formatter.allowedUnits = [ .hour, .minute, .second ] // Units to display in the formatted string
  formatter.zeroFormattingBehavior = [ .pad ] // Pad with zeroes where appropriate for the locale

  return  formatter.string(from: time)
}

import UserNotifications

struct UserData {
  var timerData : TimerData?
  var showFavoritesOnly = false
  var meditations : [Meditation]
  var newMeditation : Meditation? = nil
  
  struct TimerData {
    var endDate : Date
    var timeLeft : Double?
    var timeLeftLabel : String {

      return formatTime(time: self.timeLeft ?? 0.0) ?? "Empty"
    }
  }
}

enum AppAction {
  case addButtonTapped
  case updateNewMeditation(Meditation)
  case addMeditationDismissed
  case deleteMeditationAt(IndexSet)
  case changeCurrentTimerLabelTo(Double)
  case addMeditationWithDuration(Double)
  case updateLatestDate(Date)
  case startTimer(Date)
  case replaceOrAddMeditation( Meditation)
  case saveData
}

import SwiftUI

func appReducer( state: inout UserData, action: AppAction) -> [Effect<AppAction>] {
  switch action {
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

    
  case let .startTimer(finishDate):
    state.timerData = UserData.TimerData(endDate: finishDate)
    return []
    
  case let .updateLatestDate(currentDate):
    guard
      let date = state.timerData?.endDate,
      currentDate < date,
      DateInterval(start: currentDate, end: date).duration >= 0 else {
        state.timerData = nil
        return []
    }
    
    let seconds = DateInterval(start: currentDate, end: date).duration
    state.timerData?.timeLeft = seconds
    
    return []
    
  
  case let .changeCurrentTimerLabelTo(newT):
    if newT >= 0 {
      state.timerData?.timeLeft = newT
      return []
    }
    else {
      state.timerData = nil
      return []
    }
    
    
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
    
  }
  
}
