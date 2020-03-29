//
//  ContentView.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI


struct UserData {
  var timerData : TimerData?
  var showFavoritesOnly = false
  var meditations : [Meditation]
  var newMeditation : Meditation? = nil
  var timedMeditation : Meditation? = nil

  var meditationTypeIndex : Int = 0
  var meditationTimeIndex : Int = 0
  
  struct TimerData {
    var endDate : Date
    var timeLeft : Double?
    var timeLeftLabel : String {

      return formatTime(time: self.timeLeft ?? 0.0) ?? "Empty"
    }
  }
}

func formatTime (time: Double) -> String? {
  let formatter = DateComponentsFormatter()
  formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
  formatter.allowedUnits = [ .hour, .minute, .second ] // Units to display in the formatted string
  formatter.zeroFormattingBehavior = [ .pad ] // Pad with zeroes where appropriate for the locale

  return  formatter.string(from: time)
}

enum AppAction {
  
  case notification(NotificationAction)
  
  enum NotificationAction{
    case willPresentNotification
    case didRecieveResponse
  }
  
  case takeTimedMeditationOffDeck
  
  case pickTypeOfMeditation(Int)
  case pickMeditationTime(Int)

  
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
    
 
    
  case .notification(.willPresentNotification):

    return [Effect{callback in
      callback(.takeTimedMeditationOffDeck)
      }]

  case .notification(.didRecieveResponse):
    return [Effect{callback in
      callback(.takeTimedMeditationOffDeck)
      }]
    

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
    var updated : [Meditation] = state.meditations.reversed()
    updated.remove(atOffsets: indexSet)
    state.meditations = updated.reversed()
    return []

  case let .startTimerPushed(startDate: date, duration:seconds, type: type):
    state.timerData = UserData.TimerData(endDate: date+seconds)
    
    state.timedMeditation =  Meditation(id: UUID(),
                      date: Date().description,
                      duration: seconds,
                      hinderances: nil,
                      factors: nil,
                      entry: "",
                      title: type)

    let duration = state.timedMeditation!.duration
       
    return [
      Effect{$0(.timerFired)},
      Effect{ _ in
        NotificationHelper.singleton.scheduleNotification(notificationType: "\(type) Complete", seconds: duration)
      }
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
  
    
  case .pickTypeOfMeditation(let index) :
    state.meditationTypeIndex = index
    return []
    
  case .pickMeditationTime(let index) :
    state.meditationTimeIndex = index
    return []
    
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
      Current.file.save(meds)
      }]
    
  case .timerBottom(_):
    return []
  }
  
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


import AVFoundation


struct ContentView : View {
  struct Stater: Equatable {
    var reversedMeditations : [Meditation]
    var addEntryPopover : Bool
    var timedMeditation : Meditation?
    var newMeditation : Meditation?
  }
  
  @State private var popover = false
  
  var store: Store<UserData, AppAction>
  @ObservedObject var viewStore: ViewStore<Stater>

  @State private var timerGoing = true
  
  public init(store: Store<UserData, AppAction>) {
    self.store = store
    self.viewStore = self.store
      .scope(value: Stater.init(userData:), action: { $0 })
      .view
  }
  
  var body: some View {
    
    
    return VStack {
      NavigationView {
        List {
          ForEach(viewStore.value.reversedMeditations) { med in
            NavigationLink(destination:
              EditEntryView(meditation: med, store: self.store)
            ){
              ListItemView(entry: med)
            }
          }.onDelete { (indexSet) in
            self.store.send(.deleteMeditationAt(indexSet))
          }
          Text("Welcome the arrising, see it, let it through")
            .lineLimit(3)
            .padding()
        }
        .navigationBarTitle(Text("Practice Notes"))
        .navigationBarItems(trailing:
          Button(action: {
            self.store.send(.addButtonTapped)
          }){
          Circle()
            .frame(width: 33.0, height: 33.0, alignment: .center)
            .foregroundColor(.secondary)
        })
        
      }
      
      
      if (self.viewStore.value.timedMeditation != nil) {
        TimerBottom(
          enabled: self.$popover,
          store: self.store.scope(
            value: { TimerBottomState(
              timerData: $0.timerData,
              timedMeditation: $0.timedMeditation,
              enabled: false)
          },
            action: { .timerBottom($0) }))
      }
        
      else {
        CircleBottom(enabled: self.$popover)
      }
      
      Text("")
        .hidden()
        .sheet(isPresented: self.$popover) {
          MeditationView(store: self.store.scope(value: {$0}, action: {$0}))
      }
      
      
      
      Text("")
        .hidden()
        .sheet(
          isPresented:
          self.store.send({_ in .addMeditationDismissed },
                          viewStore: self.viewStore,
                          binding: \.addEntryPopover)
        ) { () -> EditEntryView in
          return EditEntryView(meditation: self.viewStore.value.newMeditation!,
                               store: self.store)
      }
      
    }
    .edgesIgnoringSafeArea(.bottom)
    .accentColor(Color(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)))

  }
  
  
  
}

extension ContentView.Stater {
  init(userData: UserData) {
    self.reversedMeditations = userData.meditations.reversed()
    self.addEntryPopover = userData.newMeditation.map{ _ in true } ?? false
    self.timedMeditation = userData.timedMeditation
    self.newMeditation = userData.newMeditation
  }
}





//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//  Group {
//    ContentView(store: OldStore<UserData,AppAction>.dummy)
//      .environment(\.colorScheme, .dark)
//
//    ContentView(store: OldStore<UserData,AppAction>.dummy)
//      }
//    }
//}
