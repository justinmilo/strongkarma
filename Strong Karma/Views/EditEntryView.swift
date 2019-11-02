//
//  SwiftUIView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

struct DetailState {
    
    var title : String
}

struct EditEntryView: View {
    
    var meditation : Meditation
    @ObservedObject var store: OldStore<UserData, AppAction>

  
    @State var value : String = ""
    
    @State var text : String = "Test example" {
        didSet {
            
        }
    }
    
    
    let roundedness : CGFloat = 20
    
    var background : some View =  RoundedRectangle(cornerRadius: CGFloat(20)) .foregroundColor(.white)
    
    var body: some View {
        
        let binding = Binding<String>(get: {
            self.meditation.entry ?? "No Title"
               }, set: {
                   print("text now: \(String(describing: $0))")
                self.text = $0
                var med = self.meditation
                   med.entry = $0
                self.store.send( .updateMeditation(med) )
               })
        
        
        
        return ZStack {
            AngularGradient(gradient: Gradient(colors: [Color.red, Color.blue]), center: .center).edgesIgnoringSafeArea(.all)
            VStack{
                Text(meditation.entry ?? "No Title")
                    .font(.largeTitle)
                TextField(meditation.entry ?? "No Title" , text: binding)
                    .padding(.all)
                    .background(background)
                    .padding(EdgeInsets(top: 0, leading: 25, bottom: 5, trailing: 25))
                TextView(
                    text: binding
                )
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .padding(.all)
                    .background(background)
                    .padding(EdgeInsets(top: 5, leading: 25, bottom: 0, trailing: 25))
                                
                

                    
                        
                
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
      EditEntryView( meditation: Meditation.dummy, store: OldStore<UserData, AppAction>.dummy)
    }
}
