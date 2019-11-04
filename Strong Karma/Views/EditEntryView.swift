//
//  SwiftUIView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI


struct EditEntryView: View {
  
  var meditation : Meditation
  @ObservedObject var store: OldStore<UserData, AppAction>
  
  @State var title : String
  @State var entry : String
  
  init (meditation med: Meditation, store: OldStore<UserData, AppAction>) {
    _title = State(initialValue: med.title)
    _entry = State(initialValue: med.entry)

    self.meditation = med
    self.store = store
  }
  
  
  var body: some View {
    
    
    
    return      VStack{
      Text(title)
        .font(.largeTitle)
      TextField("Title", text: self.$title, onEditingChanged: {_ in }, onCommit:updateOnCommit )
      
      TextView(
        text: self.$entry, onCommit: updateOnCommit
      )
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding(.all)
        .padding(EdgeInsets(top: 5, leading: 25, bottom: 0, trailing: 25))
    }.onDisappear() {
      self.updateOnCommit()
    }
    
  }
  func updateOnCommit() {

      
      var med = self.meditation
      med.title = self.title
      med.entry = self.entry
      print("Action should happen")
      self.store.send(  .replaceOrAddMeditation(med) )
    
  }
}



struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    EditEntryView( meditation: Meditation.dummy, store: OldStore<UserData, AppAction>.dummy)
  }
}
