//
//  NewNewMeditation.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/24/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

class MeditationTimer {
  init(store: OldStore<UserData, AppAction>) {
    self.store = store
  }
  
  var store: OldStore<UserData, AppAction>

  var timer : Timer?

  // sideEffects
  func startTimer(duration: Double) {
    
    self.store.send(.startTimer(Date() + duration))
    
    
      self.timer =  Timer.scheduledTimer(withTimeInterval: 1, repeats: true
        ){_ in
          let currentDate = Date()
          self.store.send( .updateLatestDate( currentDate ))
          
          if self.store.value.timerData == nil {
            self.timer?.invalidate()
          }
        }
    
    self.store.send( .changeCurrentTimerLabelTo(duration))
    
    self.store.scheduleNotification(notificationType: "Meditation Complete", seconds: duration) {
      self.store.send(.addMeditationWithDuration(duration))
    }
  }
  
}

struct NewMeditationView : View {
  @EnvironmentObject var store: OldStore<UserData, AppAction>
  
  @State var selMin = 0
  private let minutesList : [Double] = (1 ... 60).map(Double.init).map{$0}
  private var seconds : Double { minutesList[self.selMin]   * 60 }
  var meditationTimer : MeditationTimer {
    MeditationTimer(store: self.store)
  }

  var body: some View {

    return VStack{
      
      Text(store.value.timerData?.timeLeftLabel ?? "No Timer")
        .font(.largeTitle)
      
      Picker(selection: self.$selMin, label: Text("Min")) {
        ForEach(0 ..< self.minutesList.count) {
          Text( String(self.minutesList[$0])
          ).tag($0)
        }
      }
      
      Button(action: self.startTimer ) {
        Text("Start")
          .font(.title)
      }
      
    }.padding()
  }
  
  func startTimer() {
    self.meditationTimer.startTimer(duration: self.seconds)
  }
  
  
}



struct NewMeditationView_Previews: PreviewProvider {
    static var previews: some View {
        NewMeditationView()
    }
}
