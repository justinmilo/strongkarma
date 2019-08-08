//
//  ContentView.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI




struct Badge: View {
  var body: some View {
    Circle().foregroundColor(.black)
  }
}
struct StepperView : View {
  
  @Binding var value : Double
  var name : String
  
  var body : some View {
    Stepper(value: $value, in: 0...10) {
      HStack {
        Text(name).foregroundColor(.gray)
        Spacer()
        Circle().frame(width: 20, height: 20, alignment: .center)
        Spacer()
      }
    }
  }
}

/*
struct NoteViewStep : View {
  
  var hinderances : Hinderances?
  var factors : Factors?
  
  var body : some View {
    VStack(alignment: HorizontalAlignment.leading, spacing: nil){
      Text("Mindfulness Meditation")
      if (hinderances != nil) {
        VStack{
          Badge()
          Badge()
          Badge()
//          StepperView(value: hinderances!.desire, name: "Desire")
//          StepperView(value: $hinderances?.aversion, name: "Aversion")
//          StepperView(value: $hinderances?.anxiety, name: "Anxiety")
//          StepperView(value: $hinderances?.dullness, name: "Torpor")
//          StepperView(value: $hinderances?.doubt, name: "Doubt")
        }
      }
    }
  }
}
 */

struct FactorsView : View {
  var factors : Meditation.Factors
  var body: some View {
    Group {
      factors.faith.map {  Text("Faith \($0)") }
      factors.energy.map {  Text("Energy \($0)") }
      factors.mindfulness.map {  Text("Mindfulness \($0)") }
      factors.concentration.map {  Text("Concentration \($0)") }
      factors.insight.map {  Text("Insight \($0)") }
    }
  }
}

struct HinderancesView : View {
  var hinderances : Meditation.Hinderances
  var body: some View {
    Group {
      hinderances.desire.map {  Text("Desire \($0)") }
      hinderances.aversion.map {  Text("Aversion \($0)") }
      hinderances.anxiety.map {  Text("Anxiety \($0)") }
      hinderances.dullness.map {  Text("Dullness \($0)") }
      hinderances.doubt.map {  Text("Doubt \($0)") }
    }
  }
}

struct EntryCellView : View {
  var entry : Meditation
  
  var body : some View {
    VStack(alignment: HorizontalAlignment.leading, spacing: nil) {
      
      Text(entry.entry ?? "")
        .font(.headline)
      Text(entry.date)
      .font(.footnote)
      
      Divider().foregroundColor(.white)
      entry.factors.map(FactorsView.init)
        .foregroundColor(.gray)
      Divider()
      entry.hinderances.map(HinderancesView.init)
        .foregroundColor(.gray)
      Divider()


    }
  }
}

import AVFoundation
class MedAudio {

  var player: AVAudioPlayer? = nil

  
  func playAudioWithDelay(seconds: Double)
  {

    
    let file = Bundle.main.url(forResource: "91196__surly__buddhist-prayer-bell-cut", withExtension: "wav")

    do {
       player = try AVAudioPlayer(contentsOf: file!)
        player?.volume = 0.75
        player?.prepareToPlay()

    } catch let error as NSError {
        print("error: \(error.localizedDescription)")
    }


    //let seconds = 1.0//Time To Delay
    let when = DispatchTime.now() + seconds

    DispatchQueue.main.asyncAfter(deadline: when) {
      print(self.player)
      if self.player?.isPlaying == false {
          print("Just playing")

        self.player?.play()
        }
    }
  }
    
   
}

struct TimerButton : View {
  
  @EnvironmentObject private var userData: UserData

  
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
        
        self.userData.audioPlayer.playAudioWithDelay(seconds:
          self.delay)
        
        scheduleNotification()
        
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

import AVFoundation
struct NewMeditataion : View {
  
  private let types : [String] = ["Mindfulness of Breath", "See Hear Feel"  ]
  private let minutesList : [Double] = (0 ... 60/5).map(Double.init).map{$0*5.0}
  private let secondsList : [Double] = (0 ... 60).map(Double.init).map{$0}
  @State var selType = 0
  @State var selMin = 0
  @State var selSec = 0

  private var meditation : String { types[selType] }
  private var minutes : Double { minutesList[self.selMin] }

  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  
  var body: some View {
    
    NavigationView {
      Form{
        Button(action: {
          print(self.meditation)
          print(self.minutes)
          self.presentationMode.value.dismiss()
        }) { Text("Dismiss") }
        
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
        
        TimerButton(delay:self.minutesList[selMin] * 60 + secondsList[selSec])
          .environmentObject(UserData())
        // }
        //
      }
    }.navigationBarTitle(Text("Practice Notes"))
    
  }
  
  
  
  
  
  
    
  
}

struct ContentView2 : View {
  
  @EnvironmentObject private var userData: UserData
  @State private var popover = false
  

  
  var body: some View {
     NavigationView {

      VStack {
        
        List {
          ForEach(userData.meditations) { sec in
                EntryCellView(entry:sec)
          }
          Text("Notice the object, see it beautiful awareness, let it through")
            .lineLimit(3)
            .padding()
        }
        
        Button(action: {
          self.popover = true
        }){
          Circle()
            .frame(width: 44.0, height: 44.0, alignment: .center)
            .foregroundColor(.secondary)
          
        }
        }.navigationBarTitle(Text("Practice Notes"))
     }
      
     .sheet(isPresented: self.$popover) {
      NewMeditataion()
     }
  }
}
