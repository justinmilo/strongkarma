//
//  MeditationView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 3/16/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import SwiftUI

struct MeditationView: View {
  struct Stater : Equatable {
    var timeLeft: String
    let minutesList : [Double]
  }
  var store: Store<UserData, AppAction>
  @ObservedObject var viewStore : ViewStore<Stater>
  
  init(store:Store<UserData, AppAction> ) {
    self.store = store
    self.viewStore = store
      .scope(value: Stater.init(userData:), action: {$0})
      .view
  }

   @State var selType = 0
   @State var selMin = 0
  

  
  var body: some View {
    
    let seconds  : Double =  self.viewStore.value.minutesList[self.selMin]  * 60
    
    return VStack{
      Spacer()
      Text("Concentration")
        .font(.largeTitle)
      Spacer()
      
      Text("56:00") // timeLeft
        .foregroundColor(Color(#colorLiteral(red: 0.4843137264, green: 0.6065605269, blue: 0.9686274529, alpha: 1)))
        .font(.largeTitle)
      
      Picker("Type", selection: self.$selType) {
        ForEach(0 ..< Type.allCases.count) { index in
          Text(Type.allCases[index].rawValue).tag(index)
        }
      }.labelsHidden()
      
      Picker("Min", selection: self.$selMin) {
        ForEach(0 ..< self.viewStore.value.minutesList.count) {
          Text( String(self.viewStore.value.minutesList[$0])
          ).tag($0)
        }
      }.labelsHidden()
      
      Spacer()
      Button(action: {
        self.store.send(
          .startTimerPushed(startDate:Date(), duration: seconds, type: Type.allCases[self.selType].rawValue ))
      } ) {
        Text("Start")
          .font(.title)
      }
      Spacer()
    }
    
  }
}
extension MeditationView.Stater {
  init (userData: UserData) {
    self.minutesList = (1 ... 60).map(Double.init).map{$0}
    self.timeLeft = userData.timerData?.timeLeftLabel ?? ":"
  }
}

//struct MeditationView_Previews: PreviewProvider {
//    static var previews: some View {
//      Group {
//        MeditationView()
//
//      MeditationView()
//         .environment(\.colorScheme, .dark)
//    }
//   }
//}
