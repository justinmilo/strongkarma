//
//  ComposableArchitecture.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 11/2/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Combine
import Foundation



public typealias Reducer<Value,Action> = (inout Value, Action) -> [Effect<Action>]

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

public func logging<Value, Action>(
  _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return [Effect{ _ in
      print("Action: \(action)")
      print("Value:")
      dump(newValue)
      print("---")
    }] + effects
  }
}
