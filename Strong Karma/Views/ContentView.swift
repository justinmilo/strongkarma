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
  struct Stater: Equatable {
    var reversedMeditations : [Meditation]
    var addEntryPopover : Bool
    var timedMeditation : Meditation?
    var newMeditation : Meditation?
  }
  
  @State private var popover = false
  
  var store: Store<UserData, AppAction>
  @ObservedObject var viewStore: ViewStore<Stater>

  @State private var timerGoing = true
  
  public init(store: Store<UserData, AppAction>) {
    self.store = store
    self.viewStore = self.store
      .scope(value: Stater.init(userData:), action: { $0 })
      .view
  }
  
  var body: some View {
    
    
    return VStack {
      NavigationView {
        List {
          ForEach(viewStore.value.reversedMeditations) { med in
            NavigationLink(destination:
              EditEntryView(meditation: med, store: self.store)
            ){
              ListItemView(entry: med)
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
      
      
      if (self.viewStore.value.timedMeditation != nil) {
        TimerBottom(
          enabled: self.$popover,
          store: self.store.scope(
            value: { TimerBottomState(
              timerData: $0.timerData,
              timedMeditation: $0.timedMeditation,
              enabled: false)
          },
            action: { .timerBottom($0) }))
      }
        
      else {
        CircleBottom(enabled: self.$popover)
      }
      
      Text("")
        .hidden()
        .sheet(isPresented: self.$popover) {
          MeditationView(store: self.store.scope(value: {$0}, action: {$0}))
      }
      
      
      
      Text("")
        .hidden()
        .sheet(
          isPresented:
          self.store.send({_ in .addMeditationDismissed },
                          viewStore: self.viewStore,
                          binding: \ContentView.Stater.addEntryPopover)
        ) { () -> EditEntryView in
          return EditEntryView(meditation: self.viewStore.value.newMeditation!,
                               store: self.store)
      }
      
    }
    .edgesIgnoringSafeArea(.bottom)
    .accentColor(Color(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)))

  }
  
  
  
}

extension ContentView.Stater {
  init(userData: UserData) {
    self.reversedMeditations = userData.meditations.reversed()
    self.addEntryPopover = userData.newMeditation.map{ _ in true } ?? false
    self.timedMeditation = userData.timedMeditation
    self.newMeditation = userData.newMeditation
  }
}





//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//  Group {
//    ContentView(store: OldStore<UserData,AppAction>.dummy)
//      .environment(\.colorScheme, .dark)
//
//    ContentView(store: OldStore<UserData,AppAction>.dummy)
//      }
//    }
//}
