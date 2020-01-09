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

    var body: some View {
        HStack{
            Button(action: {
                self.items.remove(self.item.id)
            }) {
                Text("del")
            }
            Text(self.item.text)
            TextField("newtext", text:self.$text)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var items: ItemModel
    
    var body: some View {
        VStack {
            ForEach(items.items, id: \.id) { item in
                ListItem(items: self._items, item: item)
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
