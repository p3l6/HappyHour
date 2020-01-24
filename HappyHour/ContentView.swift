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
    @State var editText: String
    var item: ItemModel.Item
    
    init(item: ItemModel.Item) {
        self.item = item
        _editText = State(initialValue: item.text)
    }
    
    var body: some View {
        HStack{
            Button(action: {
                self.items.remove(self.item.id)
            }) {
                Text("del")
            }
            
            TextField("newtext", text:self.$editText, onCommit: {
                self.item.text = self.editText
                print(self.item.text)
                self.items.save()
            })
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var items: ItemModel
    
    var body: some View {
        VStack {
            ForEach(self.items.items) { item in
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
