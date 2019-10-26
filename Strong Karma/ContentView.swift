//
//  ContentView.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

func date(from string: String) -> Date? {
  let isoDate = "2016-04-14T10:44:00+0000"

  let isoDate2 = "2016-04-14 10:44:00 +0000"

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


struct ContentView2 : View {
  
  @EnvironmentObject var store: Store<UserData, AppAction>
  @State private var popover = false
  

  
  var body: some View {
     NavigationView {

      VStack {
        
        List {
          ForEach(store.value.meditations) { sec in
            NavigationLink(destination: SwiftUIView()){
                EntryCellView(entry:sec)
            }
          }
          Text("Welcome the object, let it in, see it, let it through")
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
      NewNewMeditataion()
        .environmentObject(self.store)
     }
  }
}
