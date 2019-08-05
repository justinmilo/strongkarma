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

struct ContentView2 : View {
  
  @EnvironmentObject private var userData: UserData
  @State private var popover = false
  @State private var date = Date()
  private var durations : [[String]] = {
    let hours = (0 ... 48).map(String.init)
    let minutes = (0 ... 60).map(String.init)
    let seconds = (0 ... 60).map(String.init)

    return [
      hours, minutes, seconds
    ]
  }()
  
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
            .foregroundColor(.black)
          
        }
        
        
        }.navigationBarTitle(Text("Practice Notes"))
     }
     .popover(isPresented: self.$popover) {
      
      GeometryReader { geometry in

          HStack
          {
               Picker(selection: self.$selection, label: Text(""))
               {
                    ForEach(0 ..< self.durations[0].count)
                    {
                        Text(self.durations[0][$0])
                           .tag($0)
                    }
                }
                .pickerStyle(.wheel)
                .fixedSize(horizontal: true, vertical: true)
                .frame(width: geometry.size.width / 2, height: geometry.size.height, alignment: .center)


                Picker(selection: self.$selection2, label: Text(""))
                {
                     ForEach(0 ..< self.durations[1].count)
                     {
                         Text(self.durations[1][$0])
                             .tag($0)
                     }
                }
                .pickerStyle(.wheel)
                .fixedSize(horizontal: true, vertical: true)
                .frame(width: geometry.size.width / 2, height: geometry.size.height, alignment: .center)

          }
      }
      
     }
  }
}
