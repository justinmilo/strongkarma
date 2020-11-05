//
//  Current.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/25/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
import ComposableArchitecture

extension Meditation {
    static var dummy = Meditation(
        id: UUID(),
        date: "My Date",
        duration: 50,
        entry: "Some Entry",
        title:"Untitled"
    )
  static var dummy1 = Meditation(
      id: UUID(),
      date: "11/11/11",
      duration: 50,
      entry: "Mindfulness of Breath",
      title:"Untitled"
  )
  static var dummy2 = Meditation(
      id: UUID(),
      date: "12/12/12",
      duration: 50,
      entry: "A Journey In",
      title:"Untitled"
  )
}


typealias TypResult = Result<[Meditation], LoadError>


struct FileIO {
   var load : () -> [Meditation] = _load
   var save : ([Meditation]) -> () = saveItems
}

enum LoadError : Error {
  case noData
  case badData
  case noJson
  case badURL
  case badDocumentsURL
  case couldntWrite
}


func getDocumentsURL() -> URL?{
  do {
    let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
    let fileURL = documentDirectory.appendingPathComponent("Items.json")
    return fileURL
  }
  catch {
    return nil
  }
}

func _load() -> [Meditation] {
  let documentsResult = _loadFromDocuments()
  if case .success = documentsResult {
    print ("Document loadFromDocuments ")
    return try! documentsResult.get()
  }
 let bundleResult : [Meditation] = _extraLoad("meditationsData.json")()
  print ("Document loadFromBundle ")

   saveItems(item: bundleResult)
  return bundleResult
}

func _loadFromDocuments() -> Result<[Meditation], LoadError>{
  
  guard let url = getDocumentsURL() else {
    print ("no persistenceURL ")

    return .failure( LoadError.badURL )
  }
  guard let data = try? Data(contentsOf: url) else {
    print (" LoadError.noData ")

    return .failure( LoadError.noData )
  }
  print(url)
  do {
    let decoder = JSONDecoder()
    let jsonData = try decoder.decode(Array<Meditation>.self, from: data)
    return .success(jsonData)
  } catch  {
    print (error)
    print (" LoadError.noJson ")

    return .failure(.noJson)
  }
}


let meditationsData: [Meditation] = _loadFromBundle("meditationsData.json")

func _extraLoad<T: Decodable>(_ filename: String) -> () -> T {
  return {
    _loadFromBundle(filename)
  }
}

func _loadFromBundle<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
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


func saveItems(item: Array<Meditation>) {
  let encoder = JSONEncoder()
  encoder.outputFormatting = .prettyPrinted
  let data = try! encoder.encode(item)
  do {
    if let url = getDocumentsURL() {
      try data.write(to: url)
    }else {
      fatalError()
    }
  } catch {
    fatalError()
  }
  
}
