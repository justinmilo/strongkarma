//
//  MedAudio.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/19/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
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
