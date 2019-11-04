//
//  ContentView.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

func date(from string: String) -> Date? {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
  dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
  //let date = dateFormatter.date(from:isoDate)!
  
  
 // let dateFormatter = ISO8601DateFormatter()
  let date = dateFormatter.date(from:string)
  return date
}

func formattedDate(from date:Date) -> String {
  let dateFormatterPrint = DateFormatter()
  dateFormatterPrint.dateFormat = "EEEE, MMMM d, yyyy"
  return dateFormatterPrint.string(from: date)
}


/*
 
 Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
 09/12/2018                        --> MM/dd/yyyy
 09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
 Sep 12, 2:11 PM                   --> MMM d, h:mm a
 September 2018                    --> MMMM yyyy
 Sep 12, 2018                      --> MMM d, yyyy
 Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
 2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
 12.09.18                          --> dd.MM.yy
 10:41:02.112                      --> HH:mm:ss.SSS
 */


import AVFoundation


struct ContentView : View {
  
  @ObservedObject var store: OldStore<UserData, AppAction>
  @State private var popover = false
  @State private var timerGoing = true
  private var addEntryPopover : Bool {
    if let _ = store.value.newMeditation {
      return true
    } else {
      return false
    }
  }
  
  var body: some View {
    let binding = Binding<Bool>(
    get: { self.addEntryPopover },
    set: { value in
      if value == false {
        self.store.send(.addMeditationDismissed)
      }
    })
    
    return VStack {
      NavigationView {
        List {
          ForEach(store.value.meditations) { med in
            NavigationLink(destination:
              EditEntryView(meditation: med, store: self.store)
            ){
              EntryCellView(entry: med)
            }
          }.onDelete { (indexSet) in
            self.store.send(.deleteMeditationAt(indexSet))
          }
          Text("Welcome the arrising, see it, let it through")
            .lineLimit(3)
            .padding()
        }
        .navigationBarTitle(Text("Practice Notes"))
        .navigationBarItems(trailing:
          Button(action: {
            self.store.send(.addButtonTapped)
          }){
          Circle()
            .frame(width: 33.0, height: 33.0, alignment: .center)
            .foregroundColor(.secondary)
        })
        
      }
      
      
      if (timerGoing == true) {
        TimerBottom(enabled: self.$popover, store: self.store)
      }
      
      if (timerGoing == false) {
        CircleBottom(enabled: self.$popover)
      }
      
      Text("").hidden().sheet(isPresented: self.$popover) {
        NewMeditationView()
          .environmentObject(self.store)
      }
      Text("").hidden().sheet(
        isPresented: binding){ () -> EditEntryView in
          return EditEntryView(meditation: self.store.value.newMeditation!, store: self.store)
      }
      
    }
    .edgesIgnoringSafeArea(.bottom)
    .accentColor(Color(red: 0.50, green: 0.30, blue: 0.20, opacity: 0.5))
  }
  
  
  
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
  
      ContentView(store: OldStore<UserData,AppAction>.dummy)
           
    }
}

//
//
//  NavigationLink(destination: {
//    self.store.send(.addMeditationWithDuration(300.0))
//    let index = self.store.value.meditations.count - 1
//    return EditEntryView(index: index, meditation: self.store.value.meditations[index], store: self.store)
//  }){
//    Text("+")
//  }


struct TimerBottom : View {
  @Binding var enabled : Bool
  @ObservedObject var store: OldStore<UserData, AppAction>

  var body: some View {

    Button(action: {
      self.enabled = true
    }){
      VStack {
        HStack {
          Spacer()
          Text(store.value.timerData?.timeLeftLabel ?? ":")
            .font(.title)
            .foregroundColor(.accentColor)
          Spacer()
        }
        HStack {
          Spacer()
          Text("See Hear Feel")
            .foregroundColor(.secondary)
          Spacer()
        }
      }
      .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0))
        
      .background(
        LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .top, endPoint: .bottom)
          .opacity(/*@START_MENU_TOKEN@*/0.413/*@END_MENU_TOKEN@*/)
      )
    }
  }
}

struct CircleBottom : View {
  @Binding var enabled : Bool
  var body: some View {
    Button(action: {
      self.enabled = true
    }){
      Circle()
        .frame(width: 44.0, height: 44.0, alignment: .center)
        .foregroundColor(.secondary)
      
    }
  }
}
