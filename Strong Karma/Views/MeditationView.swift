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
    var selType : Int
    var selMin  : Int
    var types : [String]
  }
  var store: Store<UserData, AppAction>
  @ObservedObject var viewStore : ViewStore<Stater>
  
  init(store:Store<UserData, AppAction> ) {
    self.store = store
    self.viewStore = store
      .scope(value: Stater.init(userData:), action: {$0})
      .view
  }
  

  
  var body: some View {

    return VStack{
      Spacer()
      Text(self.viewStore.value.currentType)
        .font(.largeTitle)
      Spacer()
      
      Text(self.viewStore.value.timeLeft) // timeLeft
        .foregroundColor(Color(#colorLiteral(red: 0.4843137264, green: 0.6065605269, blue: 0.9686274529, alpha: 1)))
        .font(.largeTitle)
      
      Picker("Type", selection:
        self.store.send(
          {.pickTypeOfMeditation($0)},
          viewStore: self.viewStore,
          binding: \.selType)) {
            ForEach(0 ..< self.viewStore.value.types.count) { index in
              Text(self.viewStore.value.types[index]).tag(index)
            }
      }.labelsHidden()
      
      Picker("Min", selection:
        self.store.send(
          {.pickMeditationTime($0)},
          viewStore: self.viewStore,
          binding: \.selMin)) {
        ForEach(0 ..< self.viewStore.value.minutesList.count) {
          Text( String(self.viewStore.value.minutesList[$0])
          ).tag($0)
        }
      }.labelsHidden()
      
      Spacer()
      Button(action: {
        self.store.send(
          .startTimerPushed(startDate:Date(), duration: self.viewStore.value.seconds, type: self.viewStore.value.currentType ))
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
    self.types = [
      "Concentration",
      "Mindfullness of Breath",
      "See Hear Feel",
      "Self Inquiry",
      "Do Nothing",
      "Positive Feel",
      "Yoga Still",
      "Yoga Flow",
      "Free Style",
    ]
    self.selType = userData.meditationTypeIndex
    self.selMin = userData.meditationTimeIndex
  }
  var seconds  : Double { self.minutesList[self.selMin]  * 60 }
  var currentType : String { self.types[self.selType]}
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
