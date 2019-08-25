//
//  NewMeditation.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/19/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import AVFoundation

struct NewNewMeditataion : View {
  @EnvironmentObject var store: Store<UserData, AppAction>
  
  @State var selMin = 0
  private let minutesList : [Double] = (1 ... 60).map(Double.init).map{$0}
  private var seconds : Double { minutesList[self.selMin] } //* 60 }


  var body: some View {

    return VStack{
      
      store.value.secondsLeft.map{ String($0) }.map{ Text($0) }
      
      
      Picker(selection: self.$selMin, label: Text("Minutes")) {
        ForEach(0 ..< self.minutesList.count) {
          Text( String(self.minutesList[$0])
          ).tag($0)
        }
      }
      
      Button(action: self.startTimer ) {
        Text("Start")
      }
      
    }
  }
  
  
  
  // sideEffects
  func startTimer() {
  
    self.targetDate = Date() + self.seconds
    let _ =  self.timer
    
    self.store.send( .changeCurrentTimerLabelTo(Int(self.seconds)))
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.scheduleNotification(notificationType: "Meditation Complete", seconds: self.seconds )
  }
  
   @State var targetDate : Date = nil
  
   

  
  
  var timer : Timer {
    Timer.scheduledTimer(withTimeInterval: 1, repeats: true
    ){_ in
      
      let currentSeconds = Calendar(identifier: .gregorian).dateComponents([.minute, .second], from: Date(), to: self.targetDate ?? Date()).second ?? 0
      
      self.store.send( .changeCurrentTimerLabelTo(currentSeconds))
    }
  }
  
  
  
}



struct NewMeditataion : View {
  
  @ObservedObject var store: Store<UserData, AppAction>
  
  private let types : [String] = ["Mindfulness of Breath", "See Hear Feel"  ]
  private let minutesList : [Double] = (0 ... 60/5).map(Double.init).map{$0*5.0}
  private let secondsList : [Double] = (0 ... 60).map(Double.init).map{$0}
  @State var selType = 0
  @State var selMin = 0
  @State var selSec = 0

  private var meditation : String { types[selType] }
  private var minutes : Double { minutesList[self.selMin] }

  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  
  @State var textFieldText : String  = ""
  
  var body: some View {
    
    NavigationView {
      Form{
        Section {
          Button(action: {
          print(self.meditation)
          print(self.minutes)
          self.presentationMode.value.dismiss()
          }) { Text("Dismiss") }
        }
        
        Section {
          Picker(selection: self.$selType, label: Text("Type")) {
            ForEach(0 ..< self.types.count) {
              Text(self.types[$0]).tag($0)
            }
          }

          Picker(selection: self.$selMin, label: Text("Minutes")) {
            ForEach(0 ..< self.minutesList.count) {
              Text( String(self.minutesList[$0])
              ).tag($0)
            }
          }
          Picker(selection: self.$selSec, label: Text("Seconds")) {
            ForEach(0 ..< self.secondsList.count) {
              Text( String(self.secondsList[$0])
              ).tag($0)
            }
          }

//          TimerButton(store: self.$store, delay:self.minutesList[selMin] * 60 + secondsList[selSec])
//            .environmentObject(UserData())

        }
//        Section {
//          TextField("Description of Meditation", text: $textFieldText, onEditingChanged: { _ in }, onCommit: {})
//            .lineLimit(nil)
//        }
        
      }
      
      
    }.navigationBarTitle(Text("Practice Notes"))
    
  }
  
  
  
  
  
  
    
  
}


