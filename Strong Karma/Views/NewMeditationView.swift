//
//  NewNewMeditation.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/24/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI


enum Type : String, CaseIterable {
  case concentration = "Concentration"
  case mindfullnessOfBreath = "Mindfullness of Breath"
  case seeHearFeel = "See Hear Feel"
  case selfInquiry = "Self Inquiry"
  case doNothing = "Do Nothing"
  case positiveFeel = "Positive Feel"
  case freeStyle = "Free Style"
}

struct NewMeditationView : View {
  @EnvironmentObject var store: OldStore<UserData, AppAction>
  
  @State var selMin = 0
  @State var selType = 0
  private let minutesList : [Double] = (1 ... 60).map(Double.init).map{$0}
  private var seconds : Double { minutesList[self.selMin]   * 60 }
  

  var timeLeft : String {
    store.value.timerData?.timeLeftLabel ?? ":"
  }
  
  
  var body: some View {

    return VStack{
      Spacer()

      Text(timeLeft).font(.largeTitle)
        
      Picker(selection: self.$selType, label: Text("Type")) {
        ForEach(0 ..< Type.allCases.count) { index in
          Text(Type.allCases[index].rawValue).tag(index)
        }
      }
      
      
      Picker(selection: self.$selMin, label: Text("Min")) {
        ForEach(0 ..< self.minutesList.count) {
          Text( String(self.minutesList[$0])
          ).tag($0)
        }
      }
      
      Button(action: {
        self.store.send(
          .startTimerPushed(startDate:Date(), duration: self.seconds, type: Type.allCases[self.selType].rawValue ))
        self.notification()
      } ) {
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
  
  func notification() {
        
    self.store.scheduleNotification(notificationType: "Meditation Complete", seconds: self.seconds) {
      self.store.send(.addMeditationWithDuration(self.seconds))
    }
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
