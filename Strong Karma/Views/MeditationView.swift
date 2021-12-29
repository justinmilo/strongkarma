//
//  MeditationView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 3/16/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct MeditationView: View {
  struct Stater : Equatable {
    var timeLeft: String
    let minutesList : [Double]
    var selType : Int
    var selMin  : Int
    var types : [String]
  }
  var store: Store<UserData, AppAction>
   
   var scopedStore : Store<Stater, AppAction> { self.store.scope(state: { Stater(userData: $0)} ) }
  
  var body: some View {
   WithViewStore( self.scopedStore ) { viewStore in
      VStack{
         Spacer()
         Text(viewStore.currentType)
            .font(.largeTitle)
         Spacer()
         
         Text(viewStore.timeLeft)
            .foregroundColor(Color(#colorLiteral(red: 0.4843137264, green: 0.6065605269, blue: 0.9686274529, alpha: 1)))
            .font(.largeTitle)
         
         
         Picker("Type", selection:
            viewStore.binding(
               get: { $0.selType },
               send: { AppAction.pickTypeOfMeditation($0) }
            )
         ){
            ForEach(0 ..< viewStore.types.count) { index in
               Text(viewStore.types[index]).tag(index)
            }
         }.labelsHidden()
        .pickerStyle(.wheel)
         
         Picker("Min", selection:
            
            viewStore.binding(
               get: { $0.selMin },
               send: { AppAction.pickMeditationTime($0) }
               )
            ) {
                 ForEach(0 ..< viewStore.minutesList.count) {
                   Text( String(viewStore.minutesList[$0])
                   ).tag($0)
                 }
               }.labelsHidden()
              .pickerStyle(.wheel)

         
         Spacer()
               Button(action: {
                 viewStore.send(
                   .startTimerPushed(startDate:Date(), duration: viewStore.seconds, type: viewStore.currentType ))
               } ) {
                 Text("Start")
                   .font(.title)
               }
               Spacer()
      }
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
  var seconds  : Double { self.minutesList[self.selMin] * 60 }
  var currentType : String { self.types[self.selType]}
}
extension UserData {
   var medStater : MeditationView.Stater {
      return MeditationView.Stater(userData: self)
   }
}

struct MeditationView_Previews: PreviewProvider {
    static var previews: some View {
      
      Group {
      MeditationView(store: Store(
        initialState: UserData(meditations: IdentifiedArray(FileIO().load()), timedMeditationVisible: false ),
         reducer: appReducer.debug(),
         environment: AppEnvironment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            now: Date.init,
            uuid: UUID.init
         )
         )
      )
      
    
      MeditationView(store: Store(
        initialState: UserData(meditations: IdentifiedArray(FileIO().load()), timedMeditationVisible: false ),
         reducer: appReducer.debug(),
         environment: AppEnvironment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            now: Date.init,
            uuid: UUID.init
         )
         )
      )
         .environment(\.colorScheme, .dark)
    }
   }
}
