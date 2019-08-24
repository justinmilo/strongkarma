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
