//
//  ContentView.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import AVFoundation

struct ContentState: Equatable {
  var reversedMeditations : [Meditation]
  var addEntryPopover : Bool
  var timedMeditation : Meditation?
  var newMeditation : Meditation?
}
extension UserData {
   var stater : ContentState {
      return ContentState(userData: self)
   }
}
extension ContentState {
   init(userData: UserData) {
     self.reversedMeditations = userData.meditations.reversed()
     self.addEntryPopover = userData.newMeditation.map{ _ in true } ?? false
     self.timedMeditation = userData.timedMeditation
     self.newMeditation = userData.newMeditation
   }
}


struct ContentView : View {
  
  
  
  var store: Store<UserData, AppAction>
  
  @State private var popover = false
  @State private var timerGoing = true
  
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

          
        }
        .edgesIgnoringSafeArea(.bottom)

      
   }
   }
}






