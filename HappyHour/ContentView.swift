//
//  ContentView.swift
//  HappyHour
//
//  Created by Paul Landers on 1/8/20.
//  Copyright © 2020 Paul Landers. All rights reserved.
//

import SwiftUI

struct ButtonStyleNoBack: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.background(Color.clear)
    }
}

struct ListRow: View {
    @EnvironmentObject var model: ItemModel
    @State var editText: String
    var item: ItemModel.Item
    
    init(item: ItemModel.Item) {
        self.item = item
        _editText = State(initialValue: item.text)
    }
    
    var body: some View {
        HStack{
            TextField("new item", text:self.$editText, onCommit: {
                if self.item.text != self.editText {
                    self.item.text = self.editText
                    print(self.item.text)
                    self.model.save()
                }
            })
            Button(action: { self.model.remove(self.item.id)}) {
                Text("🗑")
            }
            .buttonStyle(ButtonStyleNoBack())
        }
    }
}

struct List: View {
    @EnvironmentObject var model: ItemModel
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).bold()
            ForEach(self.model.items) { item in
                ListRow(item: item)
            }
            Button(action: {self.model.add("")}) {
                Text("add")
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var model: ItemModel
    
    var body: some View {
        List(title:"Today")
        .padding(Edge.Set.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ItemModel())
    }
}
