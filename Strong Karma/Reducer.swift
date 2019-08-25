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
    print("got Here store")
  }

  func send(_ action: Action) {
    self.reducer(&self.value, action)
  }
}

import AVFoundation
class MedAudio {
  var player: AVAudioPlayer? = nil
  func playAudioWithDelay(seconds: Double) {

    
    let file = Bundle.main.url(forResource: "91196__surly__buddhist-prayer-bell-cut", withExtension: "wav")

    do {
       player = try AVAudioPlayer(contentsOf: file!)
        player?.volume = 0.75
        player?.prepareToPlay()

    } catch let error as NSError {
        print("error: \(error.localizedDescription)")
    }


    //let seconds = 1.0//Time To Delay
    let when = DispatchTime.now() + seconds

    DispatchQueue.main.asyncAfter(deadline: when) {
      print(self.player)
      if self.player?.isPlaying == false {
          print("Just playing")

        self.player?.play()
        }
    }
  }
}


import UserNotifications


struct UserData {
  var secondsLeft : Int? = nil
  var audioPlayer = MedAudio()
  var showFavoritesOnly = false
  var meditations = meditationsData
}



enum AppAction {
  case changeCurrentTimerLabelTo(Int)
  case startTimer(Double)
}

import SwiftUI

func reducer( state: inout UserData, action: AppAction) -> Void {
  switch action {
  case let .changeCurrentTimerLabelTo(newT):
    state.secondsLeft = newT
    
    
  case let .startTimer(newT):
    // sideEffect
    print("New TTT")
  }
}
