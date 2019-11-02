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

  var timeLeft : String {
    store.value.timerData?.timeLeftLabel ?? ":"
  }
  
  
  var body: some View {

    return VStack{
      Spacer()

      Text(timeLeft).font(.largeTitle)
        
      Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: Text("Type")) {
        Text("Concentration").tag(1)
        Text("Mindfullness of Breath").tag(2)
        Text("See Hear Feel").tag(3)
        Text("Self Inquiry").tag(4)
        Text("Do Nothing").tag(4)
        Text("Positive Feel").tag(5)
        Text("Free Style").tag(5)
      }
      
      
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
      Spacer()

    }
    .padding()
    .background(
      LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .top, endPoint: .bottom)
        .opacity(/*@START_MENU_TOKEN@*/0.413/*@END_MENU_TOKEN@*/)
    )
      .edgesIgnoringSafeArea(.bottom)
    .accentColor(Color(red: 0.50, green: 0.30, blue: 0.20, opacity: 0.5))
  }
  
  func startTimer() {
    self.meditationTimer.startTimer(duration: self.seconds)
  }
  
  
}



struct NewMeditationView_Previews: PreviewProvider {
    static var previews: some View {
        NewMeditationView()
        .environmentObject(OldStore<UserData,AppAction>.dummy)
    }
}

func LText(_ label: String) -> some View{
  
  return
    Text(label)
      .font(.title)
      .foregroundColor(.secondary)

  
}
