//
//  EntryCellView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

struct ListItemView : View {
  var entry : Meditation
  
  var body : some View {
    VStack(alignment: HorizontalAlignment.leading, spacing: nil) {
      HStack{
      Text(entry.title)
        
        Spacer()
        Text(formatTime(time: entry.duration) ?? "Empty")
               .font(.footnote)
        .foregroundColor(.gray)
        
      }
      date(from:entry.date).map{
        Text(formattedDate(from: $0))
          .foregroundColor(.gray)
      }
      if entry.entry != "" {
        Spacer()
        Text(entry.entry)
          .foregroundColor(.gray)
      }
      Spacer()
    }
  }
}


struct EntryCellView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(entry: Meditation.dummy)
    }
}
