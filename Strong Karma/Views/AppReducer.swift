//
//  AppReducer.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 5/10/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import Foundation
import ComposableArchitecture


struct AppEnvironment {
   let scheduleNotification : (String, TimeInterval ) -> Void = { NotificationHelper.singleton.scheduleNotification(notificationType: $0, seconds: $1)
   }
   var file = FileIO()
   var mainQueue: AnySchedulerOf<DispatchQueue>
}

//let appReducer : Reducer<UserData, AppAction, AppEnvironment> = Reducer{ state, action, environment in
//   return .none
//}
//
//import SwiftUI
//struct ContentView : View {
//
//var store: Store<UserData, AppAction>
//
//var body: some View {
//   WithViewStore(self.store) { viewStore in
//      Text("\(viewStore.meditations.count)")
//   }
//}
//}
