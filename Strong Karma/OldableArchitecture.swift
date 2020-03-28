//
//  ComposableArchitecture.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 11/2/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Combine
import Foundation


final class OldStore<Value, Action>: ObservableObject  {
 
  private let notificationPlace = NotificationHelper()
  
  private let reducer: Reducer<Value,Action>
  @Published private(set) var value: Value

  
  init(initialValue: Value, reducer: @escaping Reducer<Value,Action>) {
    self.reducer = reducer
    self.value = initialValue
  }

  func send(_ action: Action) {
    let effects = self.reducer(&self.value, action)
    effects.forEach { effect in
      effect.run(self.send)
    }
  }
  
}
