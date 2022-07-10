//
//  HelloWorldView.swift
//  IndexCards
//
//  Created by Yannick Opp on 22.05.22.

import SwiftUI

struct HelloWorldView: View {
    
    var body: some View {
        Text("Hello World")
    }
}

struct MainView : View {

    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Text("Plane Count: 0")
                    .foregroundColor(Color.white)
                Spacer()
                Text("Box Count: 0")
                    .foregroundColor(Color.white)
            }   .padding()
                .frame(height: 100)
                .background(Color.blue)
            ARView()
        }
    }
}

struct ARView: View {
    
    var body: some View {
        VStack {
            Spacer()
            Text("Hello World")
            Spacer()
        }
    }
}

struct StateView: View {
    
    @State var text: String = ""
    
    var body: some View {
        TextField("Hello World", text: $text)
    }
}

struct BindingView: View {
    
    @State var text: String = ""
    
    var body: some View {
        BoundView(text: $text)
    }
}

struct BoundView: View {
    
    @Binding var text: String
    
    var body: some View {
        TextField("Hello World", text: $text)
    }
}

class DataModel: ObservableObject {
    
    @Published var list = ["A", "B", "C", "D"]
    
    func changeObject() {
        //Change Data here
        objectWillChange.send()
    }
}

struct ObservingView: View {
    
    @StateObject var data = DataModel()
    
    var body: some View {
        ForEach(data.list, id: \.self) { item in
            Text(item)
        }   .onTapGesture {
            data.list.removeLast()
        }
    }
}

struct EnvironmentView: View {
    
    @EnvironmentObject var data: DataModel
    
    var body: some View {
        ForEach(data.list, id: \.self) { item in
            Text(item)
        }   .onTapGesture {
            data.list.removeLast()
        }
    }
}

struct ChangeUIView: View {
    
    @State var textSwap: Bool = false
    @State var colorSwap: Bool = false
    
    var body: some View {
        ZStack {
            if !colorSwap {
                Color.red
            } else {
                Color.green
            }
            VStack {
                Text(textSwap ? "Hello, World!" : "Goodbye!")
                HStack {
                    Button("Swap Color") {
                        colorSwap.toggle()
                    }
                    Button("Swap Text") {
                        textSwap.toggle()
                    }
                }
            }
        }
    }
}
