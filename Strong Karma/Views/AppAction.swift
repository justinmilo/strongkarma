//
//  AppAction.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 5/10/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import Foundation


enum AppAction {
  
  case notification(NotificationAction)
  
  enum NotificationAction{
    case willPresentNotification
    case didRecieveResponse
  }
    
  case pickTypeOfMeditation(Int)
  case pickMeditationTime(Int)

  
  case addButtonTapped
  case updateNewMeditation(Meditation)
  case addMeditationDismissed
  case deleteMeditationAt(IndexSet)
  case addMeditationWithDuration(Double)
  case startTimerPushed(startDate:Date, duration:Double, type:String)
  case timerFired
  case saveData
  
  case timerBottom(TimerBottomAction)
  
  case dismissEditEntryView
   
   case didEditEntryTitle(String)
   case didEditEntryText(String)

}

enum TimerBottomAction {
  case buttonPressed
}
