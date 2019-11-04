//
//  ComposableArchitecture.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 11/2/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Combine
import Foundation

public struct Effect<A> {
  var run : (@escaping (A) -> Void) -> Void
  
  func map<B>(_ f: @escaping (A)->B) -> Effect<B> {
    return Effect<B> { callback -> Void in
      self.run( { a in
        callback(f(a))
      })
    }
  }
}


public typealias Reducer<Value,Action> = (inout Value, Action) -> [Effect<Action>]

final class OldStore<Value, Action>: ObservableObject  {
 
  private let notificationPlace = NotificationPlace()
  
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
  
  func scheduleNotification(notificationType: String, seconds: TimeInterval, completion: @escaping ()->()) {
    notificationPlace.scheduleNotification(notificationType: notificationType, seconds: seconds, completion: completion )
  }
  
  func saveStore() {
    
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
