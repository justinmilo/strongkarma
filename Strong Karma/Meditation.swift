//
//  Meditation.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation




struct Meditation : Hashable, Identifiable, Codable, Equatable {
  var id : UUID
  var date : String
  var duration : Double
  var entry : String
  var title : String
}



