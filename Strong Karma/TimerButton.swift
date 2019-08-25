//
//  TimerButton.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/19/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

struct TimerButton : View {
  
  @ObservedObject var store: Store<UserData, AppAction>

  
  var timer : Timer {
    Timer.scheduledTimer(withTimeInterval: 1, repeats: true
    ){_ in
      self.nowDate = Date()
    }
  }
  var delay : Double // in minutes
  @State var nowDate: Date = Date()
  @State var startDate : Date = nil
  @State var referenceDate : Date = nil
  let calendar = Calendar(identifier: .gregorian)
  
  func countDownString(from date: Date, until nowDate: Date) -> String {
    let components = calendar.dateComponents([.minute, .second], from: nowDate, to: date)
    return String(format: "%02dm:%02ds", components.minute ?? 0, components.second ?? 0)
  }
  
  
  var body: some View {
    HStack {
      Button(action: {
        
        self.startDate = Date()
        
        self.referenceDate = Date() + self.delay
        
        let _ = self.timer
        
        self.store.value.audioPlayer.playAudioWithDelay(seconds:
          self.delay)
        
        
      }){
        Text("Start")
          .foregroundColor(.white)
          .frame(width: 60, height: 60, alignment: .center)
          
          .background(
            Circle()
              .foregroundColor(.secondary))
        
      }
      if (referenceDate != nil && referenceDate! > nowDate) {
        Text( countDownString(from: nowDate, until: referenceDate!) )
          .font(.largeTitle)
      }
      }

      
    
  }
  
}
