//
//  SwiftUIView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

struct DetailState {
    
    var title : String
}

struct SwiftUIView: View {
    @State var value : String = ""
    @State var text : String = "Test example"
    
    let roundedness : CGFloat = 20
    
    var background : some View =  RoundedRectangle(cornerRadius: CGFloat(20)) .foregroundColor(.white)
    
    var body: some View {
        ZStack {
            AngularGradient(gradient: Gradient(colors: [Color.red, Color.blue]), center: .center).edgesIgnoringSafeArea(.all)
            VStack{
                Text(/*@START_MENU_TOKEN@*/"Hello World!"/*@END_MENU_TOKEN@*/)
                    .font(.largeTitle)
                TextField("Concentration", text: $value)
                    .padding(.all)
                    .background(background)
                    .padding(EdgeInsets(top: 0, leading: 25, bottom: 5, trailing: 25))
                TextView(
                    text: $text
                )
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .padding(.all)
                    .background(background)
                    .padding(EdgeInsets(top: 5, leading: 25, bottom: 0, trailing: 25))
                

                    
                        
                
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}

import UIKit
struct TextView: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {

        let myTextView = UITextView()
        myTextView.delegate = context.coordinator

        myTextView.font = UIFont(name: "HelveticaNeue", size: 15)
        myTextView.isScrollEnabled = true
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
        //myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)

        return myTextView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var parent: TextView

        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            print("text now: \(String(describing: textView.text!))")
            self.parent.text = textView.text
        }
    }
}
