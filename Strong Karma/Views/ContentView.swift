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
    var meditationView: MediationViewState?
    var collapsed: Bool
  var timedMeditation : Meditation?
  var newMeditation : Meditation?
  var addMeditationVisible: Bool
  var presentTimed: Bool

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
     self.meditationView = userData.mediation
     self.newMeditation = userData.newMeditation
    self.addMeditationVisible = userData.addMeditationVisible
    self.presentTimed = userData.timedMeditationVisible
       self.collapsed = userData.collapsed
   }
}


struct ContentView : View {

  var store: Store<UserData, AppAction>
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
          
          if (viewStore.collapsed){
              IfLetStore(
                self.store.scope(
                    state: { $0.timerBottomState },
                    action: AppAction.timerBottom),
                then: { newStore in
                    TimerBottom(store: newStore)
                },
                else:
                    Button(action: {
                        viewStore.send(AppAction.presentTimedMeditationButtonTapped)
                    }){
                        Circle()
                            .frame(width: 44.0, height: 44.0, alignment: .center)
                            .foregroundColor(.secondary)
                    }
              )
          } else {
             
          }
//
        Text("")
          .hidden()
          .sheet(
            isPresented: viewStore.binding(
              get:  { !$0.collapsed },
              send:  { _ in AppAction.dismissEditEntryView }
            )
          ) {
              IfLetStore(
                self.store.scope(
                    state: { $0.mediation },
                    action: AppAction.meditation),
                then: { newStore in
                    MeditationView(store: newStore)
                }
              )
          }
//
        Text("")
          .hidden()
          .sheet(
            isPresented: viewStore.binding(
              get:  { $0.addMeditationVisible },
              send:  { _ in

                print("isPresented send")

                return AppAction.addMeditationDismissed

              }
            )
          ) {
            IfLetStore( self.store.scope(
                          state: {_ in viewStore.newMeditation },
                          action: { return AppAction.editNew($0)}),
                        then: { store in
                          EditEntryView.init(store: store)
                        },
                        else: Text("Nothing here")
            )

      }
//      .edgesIgnoringSafeArea(.bottom)
   }
  }
}
}






