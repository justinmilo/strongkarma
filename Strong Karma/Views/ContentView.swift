//
//  ContentView.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI





import SwiftUI
import ComposableArchitecture



let appReducer = Reducer<UserData, AppAction, AppEnvironment>.combine(
   todoReducer.forEach(state: \UserData.meditations, action: /AppAction.edit(id:action:), environment: { _ in EditEnvironment()}),
Reducer{ state, action, environment in
  switch action {
    
 
  case .notification(.willPresentNotification):
    state.timedMeditation = nil
    return .none

  case .notification(.didRecieveResponse):
    state.timedMeditation = nil
    return .none
   
  case .addButtonTapped:
   let med = Meditation(id: UUID(),
    date: Date().description,
    duration: 300,
    hinderances: nil,
    factors: nil,
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
    
    state.timedMeditation =  Meditation(id: UUID(),
                      date: Date().description,
                      duration: seconds,
                      hinderances: nil,
                      factors: nil,
                      entry: "",
                      title: type)

    let duration = state.timedMeditation!.duration
       
    return  Effect.merge(
      Effect(value: .timerFired),
      Effect<AppAction, Never>.fireAndForget{ environment.scheduleNotification("\(type) Complete", duration)}
   )
   
  case .timerFired:
   struct TimerId: Hashable {}
   
   
   let currentDate = Date()
   guard
      let date = state.timerData?.endDate,
      currentDate < date,
      DateInterval(start: currentDate, end: date).duration >= 0 else {
         state.timerData = nil
         let tempMed = state.timedMeditation!
         state.timedMeditation = nil
         state.meditations.removeOrAdd(meditation: tempMed)
         return .none
   }
   
   let seconds = DateInterval(start: currentDate, end: date).duration
   state.timerData?.timeLeft = seconds
   
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
      Meditation(id: UUID(),
                 date: Date().description,
                 duration: seconds,
                 hinderances: nil,
                 factors: nil,
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

  @State private var timerGoing = true
  
  public init(store: Store<UserData, AppAction>) {
    self.store = store
  }
  
  var body: some View {
   WithViewStore(self.store.scope(state: \.stater)) { viewStore in
      VStack {
          NavigationView {
            List {
               ForEachStore( self.store.scope(
                  state: { $0.meditations },
                  action: AppAction.edit(id:action:)) )
               { meditationStore in
                     NavigationLink(destination:
                        EditEntryView.init(store:meditationStore)
                           .onDisappear {
                              viewStore.send(.saveData)
                        }){
                        ListItemView(store: meditationStore)
                     }
                  
              }
               .onDelete { (indexSet) in
                  viewStore.send(.deleteMeditationAt(indexSet))
               }
               
              Text("Welcome the arrising, see it, let it through")
                .lineLimit(3)
                .padding()
            }
            .navigationBarTitle(Text("Strong Karma"))
            .navigationBarItems(trailing:
              Button(action: {
                viewStore.send(.addButtonTapped)
              }){
              Circle()
                .frame(width: 33.0, height: 33.0, alignment: .center)
                .foregroundColor(.secondary)
            })

          }

          if (viewStore.timedMeditation != nil) {
            TimerBottom(
              enabled: self.$popover,
              store: self.store.scope(
                state: { TimerBottomState(
                  timerData: $0.timerData,
                  timedMeditation: $0.timedMeditation,
                  enabled: false)
              },
                action: { .timerBottom($0) }))
          }
          else {
            CircleBottom(enabled: self.$popover)
          }
//
          Text("")
            .hidden()
            .sheet(isPresented: self.$popover) {
               MeditationView(store: self.store.scope(state: {$0}, action: {$0}))
          }


//
//          Text("")
//            .hidden()
//            .sheet(
//              isPresented:
//              self.store.send({_ in .addMeditationDismissed },
//                              viewStore: viewStore,
//                              binding: \.addEntryPopover)
//            ) { () -> EditEntryView in
//              return EditEntryView(meditation: viewStore.newMeditation!,
//                                   store: self.store)
//          }
          
        }
        .edgesIgnoringSafeArea(.bottom)

      
   }
   }
}


extension UserData {
   var stater : ContentView.Stater {
      return ContentView.Stater(userData: self)
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




