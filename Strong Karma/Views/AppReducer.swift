//
//  AppReducer.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 5/10/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Models


struct AppState : Equatable {
    var listViewState: ListViewState
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
  case listAction(ListAction)
  case notification(NotificationAction)
  
  enum NotificationAction{
    case willPresentNotification
    case didRecieveResponse
  }
}

enum TimerBottomAction {
  case buttonPressed
}

struct AppEnvironment {
    var listEnv: ListEnv
}


let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    listReducer.pullback(state: \.listViewState, action: /AppAction.listAction, environment: \AppEnvironment.listEnv),
Reducer{ state, action, environment in

  switch action {
 
//  case .meditationView(.timer(.timerFired)):
//      let tempMed = state.timedMeditation!
//      state.timedMeditation = nil
//      state.meditations.removeOrAdd(meditation: tempMed)
//
//      return .none
//
  case .notification(.willPresentNotification):
      state.listViewState.meditationView!.timedMeditation = nil
    return .none

  case .notification(.didRecieveResponse):
      state.listViewState.meditationView!.timedMeditation = nil
    return .none

  case .listAction(_):
      return .none
  }
}
)



