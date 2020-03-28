import Combine
import SwiftUI


public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

public final class ViewStore<Value>: ObservableObject {
  @Published public fileprivate(set) var value: Value
  fileprivate var cancellable: Cancellable?
  
  public init(initialValue value: Value) {
    self.value = value
  }
}

extension Store where Value: Equatable {
  public var view: ViewStore<Value> {
    self.view(removeDuplicates: ==)
  }
}

extension Store {
  public func view(
    removeDuplicates predicate: @escaping (Value, Value) -> Bool
  ) -> ViewStore<Value> {
    let viewStore = ViewStore(initialValue: self.value)
    
    viewStore.cancellable = self.$value
      .removeDuplicates(by: predicate)
      .sink(receiveValue: { [weak viewStore] value in
        viewStore?.value = value
        self
      })
    
    return viewStore
  }
}

public final class Store<Value, Action> {
  private let reducer: Reducer<Value, Action>
  @Published private var value: Value
  private var viewCancellable: Cancellable?

  private var subscribers : [(Value)->Void] = []

  public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
    self.reducer = reducer
    self.value = initialValue
  }

  public func send(_ action: Action) {
    let effects = self.reducer(&self.value, action)
    effects.forEach { effect in
      effect.run(self.send)
    }
  }
  
  
  public func scope<LocalValue, LocalAction>(
    value toLocalValue: @escaping (Value) -> LocalValue,
    action toGlobalAction: @escaping (LocalAction) -> Action
  ) -> Store<LocalValue, LocalAction> {
    let localStore = Store<LocalValue, LocalAction>(
      initialValue: toLocalValue(self.value),
      reducer: { localValue, localAction in
        self.send(toGlobalAction(localAction))
        localValue = toLocalValue(self.value)
        return []
    }
    )
    localStore.viewCancellable = self.$value
      .map(toLocalValue)
      .sink  { [weak localStore] newValue in
      localStore?.value = newValue
    }
    return localStore
  }
}

extension Store {
  public func send<LocalValue,ViewStoreValue>(
    _ event: @escaping (LocalValue) -> Action,
    viewStore: ViewStore<ViewStoreValue>,
    binding keyPath: KeyPath<ViewStoreValue, LocalValue>
  ) -> Binding<LocalValue> {
    Binding<LocalValue>(
      get: { viewStore.value[keyPath: keyPath] },
    set: { value in
        self.send(event(value))
    })
  }
}

public func combine<Value, Action>(
  _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducers.flatMap { $0(&value, action) }
    return effects
  }
}


import CasePaths
public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: CasePath<GlobalAction, LocalAction>
) -> Reducer<GlobalValue, GlobalAction> {
  return { globalValue, globalAction in
   
   guard let localAction = action.extract(from: globalAction) else { return [] }
    let localEffects = reducer(&globalValue[keyPath: value], localAction)

    return localEffects.map { localEffect in
      Effect { callback in
        localEffect.run { localAction in
          callback(action.embed(localAction))
        }
      }
    }

//    return effect
  }
}



public func pullback<LocalValue, GlobalValue, Action>(
  _ reducer: @escaping Reducer<LocalValue, Action>,
  value: WritableKeyPath<GlobalValue, LocalValue>
) -> Reducer<GlobalValue, Action> {
  return { globalValue, action in
   
    let localEffects = reducer(&globalValue[keyPath: value], action)

    return localEffects.map { localEffect in
      Effect { callback in
        localEffect.run { action in
          callback(action)
        }
      }
    }

//    return effect
  }
}

public func pullback<Value, LocalAction, GlobalAction>(
  _ reducer: @escaping Reducer<Value, LocalAction>,
  action: CasePath<GlobalAction, LocalAction>
) -> Reducer<Value, GlobalAction> {
  return { value, globalAction  in
   guard let localAction = action.extract(from: globalAction) else { return [] }

   let localEffects = reducer(&value, localAction)
   
    return localEffects.map { localEffect in
          Effect { callback in
            localEffect.run { localAction in
               callback(action.embed(localAction))
            }
          }
        }

//    return effect
  }
}

/// Constrains a  a reducer's transformation along a property specified by the path
public func constrained<Whole, Part, Action>(_ reducer: @escaping Reducer<Whole, Action>, around path: WritableKeyPath<Whole,Part>  ) -> Reducer<Whole, Action> {
   return { whole, action in
      let part = whole[keyPath: path]
      let effects = reducer(&whole, action)
      whole[keyPath: path] = part
      return effects
   }
}


public func logging<Value, Action>(
  _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return [Effect { _ in
      print("Action: \(action)")
      print("Value:")
      dump(newValue)
      print("---")
    }] + effects
  }
}

public func logging<WholeValue,ValueablePart, Action>( _ path: WritableKeyPath<WholeValue, ValueablePart>,
  _ reducer: @escaping Reducer<WholeValue, Action>) -> Reducer<WholeValue, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return [Effect { _ in
      print("Action: \(action)")
      print("Value:")
      dump(newValue[keyPath: path])
      print("---")
    }] + effects
  }
}

public func logging<WholeValue,ValueablePart, Action>( _ get: @escaping (WholeValue)-> ValueablePart,
  _ reducer: @escaping Reducer<WholeValue, Action>) -> Reducer<WholeValue, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return [Effect { _ in
      print("Action: \(action)")
      print("Value:")
      dump(get(newValue))
      print("---")
    }] + effects
  }
}
