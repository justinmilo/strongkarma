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
  var timerData : TimerData?
  var showFavoritesOnly = false
  var meditations : IdentifiedArrayOf<Meditation>
  var newMeditation : Meditation? = nil
  var timedMeditation : Meditation? = nil

  var meditationTypeIndex : Int = 0
  var meditationTimeIndex : Int = 0
  
   struct TimerData : Equatable {
    var endDate : Date
    var timeLeft : Double? { didSet {
      self.timeLeftLabel = formatTime(time: self.timeLeft ?? 0.0) ?? "Empty"
    }}
    var timeLeftLabel = ""
  }
}

extension IdentifiedArray where Element == Meditation, ID == UUID {
  mutating func removeOrAdd(meditation : Meditation) {
    guard let index = (self.firstIndex{ $0.id == meditation.id }) else {
      self.append(meditation)
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
   
   case edit(id: UUID, action: EditAction)
}

enum TimerBottomAction {
  case buttonPressed
}



struct AppEnvironment {
   let scheduleNotification : (String, TimeInterval ) -> Void = { NotificationHelper.singleton.scheduleNotification(notificationType: $0, seconds: $1)
   }
   var file = FileIO()
   var mainQueue: AnySchedulerOf<DispatchQueue>
   var now : ()->Date
   var uuid : ()->UUID
}


let appReducer = Reducer<UserData, AppAction, AppEnvironment>.combine(
   todoReducer.forEach(state: \UserData.meditations, action: /AppAction.edit(id:action:), environment: { _ in EditEnvironment()}),
Reducer{ state, action, environment in
   
   struct TimerId: Hashable {}
   
  switch action {
    
 
  case .notification(.willPresentNotification):
    state.timedMeditation = nil
    return .none

  case .notification(.didRecieveResponse):
    state.timedMeditation = nil
    return .none
   
  case .addButtonTapped:
   let med = Meditation(id: environment.uuid(),
                        date: environment.now().description,
                        duration: 300,
                        entry: "",
                        title: "Untitled")
   state.newMeditation = med
   return .none
    
  case let .updateNewMeditation(updated):
    state.newMeditation = updated
    return .none

  case .addMeditationDismissed:
    let transfer = state.newMeditation!
    state.newMeditation = nil
    state.meditations.removeOrAdd(meditation: transfer)
    
    return .none
    
  case let .deleteMeditationAt(indexSet):
   // Set comes in reversed
   let reversedSet : IndexSet = IndexSet(indexSet.reversed())
   state.meditations.remove(atOffsets: reversedSet)
    
    return .none

  case let .startTimerPushed(startDate: date, duration:seconds, type: type):
    state.timerData = UserData.TimerData(endDate: date+seconds)
    
    state.timedMeditation =  Meditation(id: environment.uuid(),
                      date: environment.now().description,
                      duration: seconds,
                      entry: "",
                      title: type)

    let duration = state.timedMeditation!.duration
       
    

    return  Effect.merge(
      Effect.timer(id: TimerId(), every: 1, on: environment.mainQueue)
        .map { _ in AppAction.timerFired },
      Effect<AppAction, Never>.fireAndForget{ environment.scheduleNotification("\(type) Complete", duration)}
   )
   
  case .timerFired:
   
   let currentDate = Date()
   
   guard let date = state.timerData?.endDate,
      currentDate < date,
      DateInterval(start: currentDate, end: date).duration >= 0 else {
         state.timerData = nil
         let tempMed = state.timedMeditation!
         state.timedMeditation = nil
         state.meditations.removeOrAdd(meditation: tempMed)

         return Effect.cancel(id: TimerId())
   }
   
   let seconds = DateInterval(start: currentDate, end: date).duration
   state.timerData?.timeLeft = seconds
   
    return .none
   return Effect.timer(id: TimerId(), every: 1.0, tolerance: .zero, on: environment.mainQueue)
      .map { _ in AppAction.timerFired }

   
  case .pickTypeOfMeditation(let index) :
    state.meditationTypeIndex = index
    return .none
    
  case .pickMeditationTime(let index) :
    state.meditationTimeIndex = index
    return .none
    
  case let .addMeditationWithDuration(seconds):
    state.meditations.append(
      Meditation(id: environment.uuid(),
                 date: environment.now().description,
                 duration: seconds,
                 entry: "",
                 title: "Untitled"
    ))
    return .none
    
    
  case .saveData:
    let meds = state.meditations
    
    return
      Effect.fireAndForget {
         environment.file.save(Array(meds))
    }
    
  case .timerBottom(_):
   return .none
   
   case .dismissEditEntryView:
   return Effect(value: .saveData)
      
  
  
  case .edit(id: let id, action: let action):
   return .none
   }
  
}
)



