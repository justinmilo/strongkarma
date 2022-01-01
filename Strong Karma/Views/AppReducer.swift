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
  var meditations : IdentifiedArrayOf<Meditation>
  var meditationsReversed: IdentifiedArrayOf<Meditation> {
    IdentifiedArrayOf<Meditation>( self.meditations.reversed() )
  }

    var mediation: MediationViewState?
  var newMeditation : Meditation? = nil
  var timedMeditationVisible: Bool = false
  var addMeditationVisible: Bool = false
    var collapsed: Bool = true

  var meditationTypeIndex : Int = 0
  var meditationTimeIndex : Int = 0
    
    var timerBottomState: TimerBottomState?{
        get{
            guard let meditationView = self.mediation else { return nil }
            
            return TimerBottomState(timerData: meditationView.timerData, timedMeditation: meditationView.timedMeditation, enabled: true)
            }
        set{
            if let newValue = newValue {
                self.mediation!.timerData = newValue.timerData
                self.mediation!.timedMeditation = newValue.timedMeditation
            }
        }
    }
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
   
  
  case notification(NotificationAction)
  
  enum NotificationAction{
    case willPresentNotification
    case didRecieveResponse
  }
  
  case addButtonTapped
  case updateNewMeditation(Meditation)
  case addMeditationDismissed
  case deleteMeditationAt(IndexSet)
  case addMeditationWithDuration(Double)
  case saveData
  case timerBottom(TimerBottomAction)
  
  case dismissEditEntryView
    
    case meditation(MediationViewAction)
   
   case edit(id: UUID, action: EditAction)
  case presentTimedMeditationButtonTapped
  case editNew(EditAction)
}

enum TimerBottomAction {
  case buttonPressed
}



struct AppEnvironment {
   var file = FileIO()
   var now : ()->Date
   var uuid : ()->UUID
    var medEnv: MediationViewEnvironment
}


let appReducer = Reducer<UserData, AppAction, AppEnvironment>.combine(
   todoReducer.forEach(state: \UserData.meditations, action: /AppAction.edit(id:action:), environment: { _ in EditEnvironment()}),
   mediationReducer.optional.pullback(state: \UserData.mediation, action: /AppAction.meditation, environment: \AppEnvironment.medEnv),
  
Reducer{ state, action, environment in
   
  
   
  switch action {
  case .meditation(_):
      return .none
//  case .meditationView(.timer(.timerFired)):
//      let tempMed = state.timedMeditation!
//      state.timedMeditation = nil
//      state.meditations.removeOrAdd(meditation: tempMed)
//
//      return .none
//
  case .notification(.willPresentNotification):
      state.mediation!.timedMeditation = nil
    return .none

  case .notification(.didRecieveResponse):
      state.mediation!.timedMeditation = nil
    return .none
   
  case .addButtonTapped:
    state.addMeditationVisible = true
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
    state.addMeditationVisible = false
    
    return Effect(value: .saveData)
    
  case let .deleteMeditationAt(indexSet):
   // Set comes in reversed
   let reversedSet : IndexSet = IndexSet(indexSet.reversed())
   state.meditations.remove(atOffsets: reversedSet)
    
    return .none
   
  
    
  case let .addMeditationWithDuration(seconds):
    state.meditations.insert(
      Meditation(id: environment.uuid(),
                 date: environment.now().description,
                 duration: seconds,
                 entry: "",
                 title: "Untitled"
    ),at: 0)
    return .none
    
    
  case .saveData:
    let meds = state.meditations
    
    return
      Effect.fireAndForget {
         environment.file.save(Array(meds))
    }
    
  case .timerBottom(.buttonPressed):
      state.timedMeditationVisible = true
   return .none
   
   case .dismissEditEntryView:
    state.timedMeditationVisible = false
      state.collapsed = true

   return Effect(value: .saveData)
      
  
  
  case .edit(id: let id, action: let action):
   return .none
    
  case .presentTimedMeditationButtonTapped:
    state.timedMeditationVisible = true
      state.collapsed = false
      state.mediation = MediationViewState()
    return .none
    
  case .editNew(.didEditText(let string)):
    state.newMeditation!.entry = string
    return .none

  case .editNew(.didEditTitle(let string)):
    state.newMeditation!.title = string
    return .none

   }
}
)



