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
    let listKey: ItemModel.ListKeyPath

    init(item: ItemModel.Item, listKey: ItemModel.ListKeyPath) {
        self.item = item
        self.listKey = listKey
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
            Button(action: { self.model.remove(self.item.id, keyPath:self.listKey)}) {
                Text("🗑")
            }
            .buttonStyle(ButtonStyleNoBack())
        }
    }
}

struct List: View {
    @EnvironmentObject var model: ItemModel
    @State var editText: String = ""
    let title: String
    let listKey: ItemModel.ListKeyPath
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).bold()
            ForEach(self.model[keyPath: listKey]) { item in
                ListRow(item: item, listKey:self.listKey)
            }
            TextField("new item", text:self.$editText, onCommit: {
                if self.editText.count > 0 {
                    self.model.add(self.editText, keyPath:self.listKey)
                    print(self.editText)
                    self.editText = ""
                    self.model.save()
                }
            })
        }
        .padding(Edge.Set.horizontal)
    }
}

struct Toolbar: View {
    @EnvironmentObject var model: ItemModel

    var body: some View {
        HStack {
            Text("PR 1234")
            Text("PR1234")
            Spacer()
            Divider()
            Button(action: { self.model.clear() }) {
                Text("Clear")
            }
            Button(action: {
                let text = self.model.formatted()
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
                pasteboard.setString(text, forType: NSPasteboard.PasteboardType.string)
            }) {
                Text("Copy Report")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .border(Color.secondary, width: 4)
    }
}

struct ContentView: View {
    @EnvironmentObject var model: ItemModel
    
    var body: some View {
        VStack {
            List(title:"Planned", listKey: \.planned)
            List(title:"Today", listKey: \.today)
            List(title:"Tomorrow", listKey: \.tomorrow)
            List(title:"QBI", listKey: \.qbi)
            Spacer()
            Toolbar()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ItemModel())
    }
}
