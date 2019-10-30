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

final class OldStore<Value, Action>: ObservableObject  {
 
  private let notificationPlace = NotificationPlace()
  
  
  let reducer: (inout Value, Action) -> Void
  @Published private(set) var value: Value

  let actionCallback: (Value) -> ()
  
  init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void, callback: @escaping (Value) -> () ) {
    self.reducer = reducer
    self.value = initialValue
    print("got Here store")
    actionCallback = callback
  }

  func send(_ action: Action) {
    self.reducer(&self.value, action)
    
    self.actionCallback(self.value)
  }
  
  func scheduleNotification(notificationType: String, seconds: TimeInterval, completion: @escaping ()->()) {
    notificationPlace.scheduleNotification(notificationType: notificationType, seconds: seconds, completion: completion )
  }
  
  func saveStore() {
    
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

struct TimerData {
  var endDate : Date
  var timeLeft : Double?
  var timeLeftLabel : String {

    return formatTime(time: self.timeLeft ?? 0.0) ?? "Empty"
  }
}

struct UserData {
  var timerData : TimerData?
  var showFavoritesOnly = false
  var meditations : [Meditation]
}



enum AppAction {
  case changeCurrentTimerLabelTo(Double)
  case addMeditationWithDuration(Double)
  case updateLatestDate(Date)
  case startTimer(Date)
  case updateMeditation(Int, Meditation)
}

import SwiftUI

func reducer( state: inout UserData, action: AppAction) -> Void {
  switch action {
  case let .startTimer(finishDate):
    state.timerData = TimerData(endDate: finishDate)
    
  case let .updateLatestDate(currentDate):
    if let date = state.timerData?.endDate, currentDate < date {
      let seconds = DateInterval(start: currentDate, end: date).duration
      if seconds >= 0 {
        state.timerData?.timeLeft = seconds
      }
      else {
        state.timerData = nil
      }
    }else {
      state.timerData = nil
    }
  
  case let .changeCurrentTimerLabelTo(newT):
    print(newT)
    if newT >= 0 {
      state.timerData?.timeLeft = newT
    }
    else {
      state.timerData = nil
    }
    
    
  case let .addMeditationWithDuration(seconds):
    state.meditations.append(
      Meditation(id: UUID(),
                 date: Date().description,
                 duration: seconds,
                 hinderances: nil,
                 factors: nil,
                 entry: nil //,
                 //title: "Untitled"
    ))
    
  case let .updateMeditation(index, meditation):
    state.meditations[index] = meditation
  }
}
