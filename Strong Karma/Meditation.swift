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
  var entry : String?
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


extension Meditation {
  private enum CodingKeys: String, CodingKey{
    case id
    case date
    case duration
    case hinderances
    case factors
    case entry
    case title
  }
  
  init(from decoder: Decoder) throws{
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    date = try container.decode(String.self, forKey: .date)
    duration = try container.decode(Double.self, forKey: .duration)
    hinderances = try container.decode(Hinderances.self, forKey: .hinderances)
    factors = try container.decode(Factors.self, forKey: .factors)
    entry = try container.decode(String.self, forKey: .entry)
    title = (try container.decodeIfPresent(String.self, forKey: .title)) ?? "No Title"
  }
  
  
}

