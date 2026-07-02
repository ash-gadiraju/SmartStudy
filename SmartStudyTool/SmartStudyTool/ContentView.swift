//
//  ContentView.swift
//  SmartStudyTool
//  Embedder: BGE
//  Embedder documentation: https://bge-model.com/Introduction/installation.html
// Text field documentation: https://developer.apple.com/documentation/swiftui/textfield
// i'M SO STUPID THE BGE THING IS PYTHON AAAAHHHH NO NOT BACKENED SOB
//  Created by Ashritha Gadiraju on 6/2/26.
//

import SwiftUI

// Questionss pipeline:
// user enters prompt for quiz --> app sends prompt to Chroma thru embedder ✅
// Chroma gets relevant data --> sends to app ✅
// app builds prompt for Ollama --> Ollama generates response for app ✅
// App gives user questions ✅
// Answers pipeline:
// user gives answers to app --> Apps sends question, correct solution, and user answer to Ollama✅
// Ollama grades --> Sends evaluation to app✅
// App sends evaluation and correct answers to user✅


// Swift pipeline:
// User enters their question into a box
// App sends contents of box to backend
// Backend returns Ollama answer
struct ContentView: View {
    @State private var question: String = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            TextField(
                        "Ask anything!",
                        text: $question
                    )
        }
        .padding()
        .textFieldStyle(.roundedBorder)
    }
    
}

#Preview {
    APIService()
}
