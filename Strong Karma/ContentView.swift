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
  
  @EnvironmentObject var store: OldStore<UserData, AppAction>
  @State private var popover = false
  @State private var timerGoing = true
  
  var body: some View {
    NavigationView {
      VStack {
        List {
          ForEach(0..<store.value.meditations.count) { sec in
            NavigationLink(destination: SwiftUIView(index: sec, meditation: self.store.value.meditations[sec])){
              EntryCellView(entry:
                self.store.value.meditations[sec])
            }
          }
          Text("Welcome the arrising, see it, let it through")
            .lineLimit(3)
            .padding()
          
         
        }
        
        if (timerGoing == true) {

          Button(action: {
            self.popover = true
          }){
            VStack {
            HStack {
              Spacer()
              Text("5:00")
                .font(.title)
                //.fontWeight(.heavy)
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
        if (timerGoing == false) {
          Button(action: {
            self.popover = true
          }){
            Circle()
              .frame(width: 44.0, height: 44.0, alignment: .center)
              .foregroundColor(.secondary)
            
          }
        }
      }
      .navigationBarTitle(Text("Practice Notes"))
      .edgesIgnoringSafeArea(.bottom)
      
    }
      
    .sheet(isPresented: self.$popover) {
      NewMeditationView()
        .environmentObject(self.store)
    }
    .accentColor(Color(red: 0.50, green: 0.30, blue: 0.20, opacity: 0.5))
  }
}



struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
            .environmentObject(OldStore<UserData,AppAction>.dummy)
    }
}
