//
//  EntryCellView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

struct EntryCellView : View {
  var entry : Meditation
  
  var body : some View {
    VStack(alignment: HorizontalAlignment.leading, spacing: nil) {
      
      Text(entry.entry ?? "")
        .font(.headline)
      date(from:entry.date).map{
        Text(formattedDate(from: $0))
          .foregroundColor(.gray)
      }
      Text(formatTime(time: entry.duration) ?? "Empty")
        .font(.footnote)
      
      
      entry.factors.map(FactorsView.init)
        .foregroundColor(.gray)
      entry.hinderances.map(HinderancesView.init)
        .foregroundColor(.gray)

    }
  }
}


struct EntryCellView_Previews: PreviewProvider {
    static var previews: some View {
        EntryCellView(entry: Meditation(id: UUID(), date: "My Date", duration: 50, hinderances: nil, factors: nil, entry: "Some Entry"))
    }
}
