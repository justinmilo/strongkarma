//
//  Meditation.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation




struct Meditation : Hashable, Identifiable, Codable {
  var id : Int
  var date : String
  var hinderances : Hinderances?
  var factors : Factors?
  var entry : String?
  
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


final class UserData: ObservableObject {
  var audioPlayer = MedAudio()
    @Published var showFavoritesOnly = false
    @Published var meditations = meditationsData
}

let meditationsData: [Meditation] = load("meditationsData.json")

func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
