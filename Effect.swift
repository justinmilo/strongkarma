//
//  Effect.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 11/6/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

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

extension Effect {
  func recieve(on queue: DispatchQueue) -> Effect {
    return Effect{ callback in
      self.run { a in
        queue.async { callback(a) }
      }
    }
  }
  
  func run(on queue: DispatchQueue) -> Effect {
    return Effect { callback in
      queue.async {
        self.run({a in callback(a) })
      }
    }
  }
}


// isPrim Effect work -> Callback
// isPrim.run Effect  Effect work -> Callback

// b.run({ b in print(b) })
// ... b.run( { ... run in background

extension Effect {
  func cancellable(id: String) -> Effect {
    _cancelled[id] = false
    return Effect { callback in
      // if
      if let shouldCancel = _cancelled[id], shouldCancel==true {
        return
      }
      // else
      self.run{ a in
        callback(a)
      }
    }
  }
  static func cancel(id: String) -> Effect {
    return Effect{callback in
      _cancelled[id] = true
    }
  }
  
}

var _cancelled : [String:Bool] = [:]
