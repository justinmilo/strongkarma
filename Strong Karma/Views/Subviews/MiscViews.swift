//
//  MiscViews.swift
//  Strong Karma
//
//  Created by Justin Smith on 9/15/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI



struct Badge: View {
  var body: some View {
    Circle().foregroundColor(.black)
  }
}
struct StepperView : View {
  
  @Binding var value : Double
  var name : String
  
  var body : some View {
    Stepper(value: $value, in: 0...10) {
      HStack {
        Text(name).foregroundColor(.gray)
        Spacer()
        Circle().frame(width: 20, height: 20, alignment: .center)
        Spacer()
      }
    }
  }
}

