//
//  TimerBottom.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 3/28/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct TimerBottomState {
  var timerData : UserData.TimerData?
  var timedMeditation : Meditation? = nil
  var enabled : Bool
}



struct TimerEnvironment {}

let timerBottomReducer = Reducer<TimerBottomState,TimerBottomAction, TimerEnvironment> {
  state, action, env in
  switch action {
  case .buttonPressed:
    state.enabled = true
    return .none
  }
}

struct TimerBottom : View {
  struct State : Equatable {
    var timeLeftLabel : String
    var meditationTitle : String
  }
 
  public init(enabled: Binding<Bool>, store: Store<TimerBottomState, TimerBottomAction>) {
    self._enabled = enabled
    self.store = store
    self.viewStore = self.store
      .scope(value: State.init(timerBottomState:), action: { $0 })
      .view
  }
  
  @Binding var enabled : Bool
  var store: Store<TimerBottomState, TimerBottomAction>
  @ObservedObject var viewStore: ViewStore<State, TimerEnvironment>


  var body: some View {

    Button(action: {
      self.enabled = true
    }){
      VStack {
        HStack {
          Spacer()
          Text(self.viewStore.value.timeLeftLabel)
            .font(.title)
            .foregroundColor(.accentColor)
          Spacer()
        }
        HStack {
          Spacer()
          Text(self.viewStore.value.meditationTitle)
              .foregroundColor(.secondary)
          Spacer()
        }
      }
      .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0))
        
      .background(
        LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .top, endPoint: .bottom)
          .opacity(/*@START_MENU_TOKEN@*/0.413/*@END_MENU_TOKEN@*/)
      )
    }
  }
}

extension TimerBottom.State {
  init (timerBottomState : TimerBottomState){
    self.meditationTitle = timerBottomState.timedMeditation?.title ?? ""
    self.timeLeftLabel = timerBottomState.timerData?.timeLeftLabel ?? ":"
  }
}

struct CircleBottom : View {
  @Binding var enabled : Bool
  var body: some View {
    Button(action: {
      self.enabled = true
    }){
      Circle()
        .frame(width: 44.0, height: 44.0, alignment: .center)
        .foregroundColor(.secondary)
      
    }
  }
}
