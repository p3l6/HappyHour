//
//  ContentView.swift
//  HappyHour
//
//  Created by Paul Landers on 1/8/20.
//  Copyright © 2020 Paul Landers. All rights reserved.
//

import SwiftUI

struct ListItem: View {
    @EnvironmentObject var items: ItemModel
    let item: ItemModel.Item
    @State private var text: String = "NIL"
    
    init(item: ItemModel.Item) {
        self.item = item
        text = self.item.text
    }

    var body: some View {
        HStack{
            Button(action: {
                self.items.remove(self.item.id)
            }) {
                Text("del")
            }
            TextField("newtext", text:self.$text, onCommit: {
                self.items.update(self.item.id, to: self.text)
            })
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var items: ItemModel
    
    var body: some View {
        VStack {
            ForEach(items.items, id: \.id) { item in
                ListItem(item: item)
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
