//
//  ContentView.swift
//  HappyHour
//
//  Created by Paul Landers on 1/8/20.
//  Copyright © 2020 Paul Landers. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var items: ItemModel
    @State private var text: String = "NIL"
    
    var body: some View {
        VStack {
            ForEach(items.items, id: \.self) { item in
                HStack{
                    Button(action: {
                        self.items.remove(item)
                    }) {
                        Text("del")
                    }
                    Text(item)
                    TextField("newtext", text:self.$text)
                }
            }
            Button(action: {
                self.items.add("new item")
            }) {
                Text("add")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ItemModel())
    }
}
