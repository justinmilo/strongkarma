//
//  SwiftUIView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI


struct EditEntryView: View {
  struct Stater : Equatable { }
  
  var meditation : Meditation
  var store: Store<UserData, AppAction>
  @ObservedObject var viewStore : ViewStore<Stater>
  
  @State var title : String
  @State var entry : String
  
  init (meditation med: Meditation, store: Store<UserData, AppAction>) {
    _title = State(initialValue: med.title)
    _entry = State(initialValue: med.entry)

    self.meditation = med
    self.store = store
    self.viewStore = store
      .scope(value: {_ in Stater()}, action: {$0})
      .view
  }
  
  
  var body: some View {
    VStack{
      TextField("Title", text: self.$title, onEditingChanged: {_ in }, onCommit:updateOnCommit )
        .padding(EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 25))
        .font(.largeTitle)
      TextView(
        text: self.$entry, onCommit: updateOnCommit
      )
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
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


//
//struct SwiftUIView_Previews: PreviewProvider {
//  static var previews: some View {
//
//   Group {
//      EditEntryView( meditation: Meditation.dummy, store: OldStore<UserData, AppAction>.dummy)
//         .environment(\.colorScheme, .dark)
//
//      EditEntryView( meditation: Meditation.dummy, store: OldStore<UserData, AppAction>.dummy)
//   }
//   }
//  }

