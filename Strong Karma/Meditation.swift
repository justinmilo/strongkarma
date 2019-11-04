//
//  Meditation.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation




struct Meditation : Hashable, Identifiable, Codable {
  var id : UUID
  var date : String
  var duration : Double
  var hinderances : Hinderances?
  var factors : Factors?
  var entry : String
  var title : String
  
  // Record of factors
  struct Factors : Hashable, Codable {
    var faith : Double?
    var energy : Double?
    var mindfulness : Double?
    var concentration : Double?
    var insight : Double?
  }

  struct Hinderances : Hashable, Codable {
    var desire : Double?
    var aversion : Double?
    var anxiety : Double?
    var dullness : Double?
    var doubt : Double?
  }
}



