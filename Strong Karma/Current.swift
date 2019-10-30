//
//  Current.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/25/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation

extension Meditation {
    static var dummy = Meditation(
        id: UUID(),
        date: "My Date",
        duration: 50,
        hinderances: nil,
        factors: nil,
        entry: "Some Entry"
        //, title:"Untitled"
    )
}

struct World {
  var file = FileIO()
}
var Current = World()

typealias TypResult = Result<[Meditation], LoadError>


struct FileIO {
  var persistenceURL : URL? = getDocumentsURL()
  var load : () -> [Meditation] = _load
  var loadFromBundle : () -> [Meditation]  = _extraLoad("meditationsData.json")
  var loadFromDocuments : () -> TypResult = _loadFromDocuments
  var save : (Array<Meditation>) -> () = saveItems
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
  let documentsResult = Current.file.loadFromDocuments()
  if case .success = documentsResult {
    return try! documentsResult.get()
  }
  let bundleResult = Current.file.loadFromBundle()
  //if case let .success(itemList) = bundleResult {
  //TODO decouple
    Current.file.save(bundleResult)//itemList)
  return bundleResult
  //  return  try! documentsResult.get()
//  }
//
//  return  try! bundleResult.get()
  
}

func _loadFromDocuments() -> Result<[Meditation], LoadError>{
  
  guard let url = Current.file.persistenceURL else {
    return .failure( LoadError.badURL )
  }
  guard let data = try? Data(contentsOf: url) else {
    return .failure( LoadError.noData )
  }
  do {
    let decoder = JSONDecoder()
    let jsonData = try decoder.decode(Array<Meditation>.self, from: data)
    return .success(jsonData)
  } catch  {
    return .failure( .noJson )
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
    if let url = Current.file.persistenceURL {
      try data.write(to: url)
    }else {
      fatalError()
    }
  } catch {
    fatalError()
  }
  
}