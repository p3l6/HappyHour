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
            Text("❖")
            TextField("new item", text:self.$editText, onCommit: {
                if self.item.text != self.editText {
                    self.item.text = self.editText
                    print(self.item.text)
                    self.model.save()
                }
            })
                .onExitCommand(perform: { NSApp.keyWindow?.makeFirstResponder(nil) })
                .textFieldStyle(PlainTextFieldStyle())
            Button(action: { self.model.moveUp(self.item.id, keyPath:self.listKey)}) {
                Text("↑")
            }.buttonStyle(ButtonStyleNoBack())
            Button(action: { self.model.moveDown(self.item.id, keyPath:self.listKey)}) {
                Text("↓")
            }.buttonStyle(ButtonStyleNoBack())
            Button(action: { self.model.remove(self.item.id, keyPath:self.listKey)}) {
                Text("🗑")
            }.buttonStyle(ButtonStyleNoBack())
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
                .onExitCommand(perform: { NSApp.keyWindow?.makeFirstResponder(nil) })
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(Edge.Set.horizontal)
    }
}

struct TimerBar: View {
    @ObservedObject var timer = TaskTimer()
    
    func statusColor(_ stat:TaskTimer.Status) -> Color {
        switch stat {
        case .idle: return Color.clear
        case .running: return Color.gray
        case .finished: return Color.blue
        }
    }
    
    var body: some View {
        HStack {
            if self.timer.status == .idle {
                Text("Start Focus Timer:")
                Spacer()
                Button(action: { self.timer.start() }) { Text("5 sec") }
            } else if self.timer.status == .running {
                Text("Focus Timer is running:")
                Spacer()
                Button(action: { self.timer.reset() }) { Text("Cancel") }
            } else { // status is .finished
                Text("Focus Timer Finished:")
                Spacer()
                Button(action: { self.timer.reset() }) { Text("Okay!") }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(statusColor(self.timer.status))
        .border(Color.secondary, width: 4)
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
                Text("Reset")
            }
            Button(action: {
                let text = self.model.formatted()
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([NSPasteboard.PasteboardType.rtf], owner: nil)
                pasteboard.writeObjects([text])
            }) {
                Text("Copy")
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
            Text(model.filename ?? "Date").bold()
            List(title:"Planned", listKey: \.planned)
            List(title:"Today", listKey: \.today)
            List(title:"Tomorrow", listKey: \.tomorrow)
            List(title:"QBI", listKey: \.qbi)
            Spacer().layoutPriority(1)
            TimerBar()
            Toolbar()
        }
        .padding()
        .frame(minWidth: 550, maxWidth: .infinity,
               minHeight: 625, maxHeight: .infinity,
               alignment: .topLeading)
    }
}


struct ContentView_Previews: PreviewProvider {
    static func sampleData() -> ItemModel {
        let model = ItemModel()
        model.add("Thing that was planned", keyPath: \.planned)
        model.add("Thing that was done", keyPath: \.today)
        model.add("Another thing done", keyPath: \.today)
        model.add("Something for tomorrow", keyPath: \.tomorrow)
        model.add("A really long thing that was done so that it won't all fit in one line at the default width and need to wrap.", keyPath: \.qbi)
        return model
    }
    
    static var previews: some View {
        ContentView().environmentObject(self.sampleData())
    }
}
