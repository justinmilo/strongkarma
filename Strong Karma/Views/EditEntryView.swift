//
//  SwiftUIView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture


struct EditEntryView: View {
  var store: Store<UserData, AppAction>
  
  var body: some View {
   
   WithViewStore(self.store) {
      viewStore in
      VStack{
         TextField("Title", text: viewStore.binding(
            get: { $0.editMeditation!.title },
            send: { .didEditEntryTitle($0) }
         ))
            //TextField("Title", text: self.$title, onEditingChanged: {_ in }, onCommit:updateOnCommit )
            .padding(EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 25))
            .font(.largeTitle)
         TextView(text: viewStore.binding(
            get: { $0.editMeditation!.entry },
            send: { .didEditEntryText($0) }
         ))
            //TextView( text: self.$entry, onCommit: updateOnCommit )
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding(EdgeInsets(top: 5, leading: 25, bottom: 0, trailing: 25))
      }.onDisappear() {
         viewStore.send( .dismissEditEntryView )
    }
   
   }
  
   }
}

