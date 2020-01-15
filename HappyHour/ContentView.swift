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
    var itemId: ItemModel.ItemIdentifier

    var body: some View {
        HStack{
            Button(action: {
                self.items.remove(self.itemId)
            }) {
                Text("del")
            }
            TextField("newtext", text:self.$items.items[self.itemId].text, onCommit: {
                print(self.items.items[self.itemId].text)
            })
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var items: ItemModel
    
    var body: some View {
        VStack {
            ForEach(self.items.items) { item in
                ListItem(itemId: item.id)
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
