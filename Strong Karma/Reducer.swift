//
//  Reducer.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/24/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation

final class Store<Value, Action>: ObservableObject {
  let reducer: (inout Value, Action) -> Void
  @Published private(set) var value: Value

  init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
    self.reducer = reducer
    self.value = initialValue
  }

  func send(_ action: Action) {
    self.reducer(&self.value, action)
  }
}

final class UserData: ObservableObject {
  var audioPlayer = MedAudio()
    @Published var showFavoritesOnly = false
    @Published var meditations = meditationsData
}



enum AppAction {
  
}

func reducer(inout state: UserData, action: AppAction) -> Void {
  
}
