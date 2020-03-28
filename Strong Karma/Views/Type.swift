//
//  NewNewMeditation.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/24/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI


enum Type : String, CaseIterable {
  case concentration = "Concentration"
  case mindfullnessOfBreath = "Mindfullness of Breath"
  case seeHearFeel = "See Hear Feel"
  case selfInquiry = "Self Inquiry"
  case doNothing = "Do Nothing"
  case positiveFeel = "Positive Feel"
  case yogaStill = "Yoga Still"
  case yogaFlow = "Yoga Flow"
  case freeStyle = "Free Style"
}


func LText(_ label: String) -> some View{
  
  return
    Text(label)
      .font(.title)
      .foregroundColor(.secondary)

  
}
