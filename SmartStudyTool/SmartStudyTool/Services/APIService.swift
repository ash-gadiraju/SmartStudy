//
//  ContentView.swift
//  SmartStudyTool
//
//  Embedder: BGE
//  Embedder documentation: https://bge-model.com/Introduction/installation.html
//
//  Created by Ashritha Gadiraju on 6/2/26.
//
//  Pipeline overview:
//  Questions: user prompt -> Chroma (via embedder) -> relevant context
//             -> Ollama prompt -> generated questions -> shown to user
//  Answers:   user answer -> Ollama (question + correct answer + user answer)
//             -> grading -> evaluation shown to user
//

import SwiftUI

// MARK: - Models

/// A single response item returned by the backend.
struct QuizResponse: Codable, Identifiable {
    var id: String { response }
    let response: String
}

// MARK: - Networking

// Basically just allows the backend and front end to communicate via a local host
@MainActor
final class BackendService {
    static let shared = BackendService()

    private let baseURL = URL(string: "http://localhost:8000")!

    private init() {}

    // Fetches quiz items from the `/items` endpoint.
    func fetchItems() async throws -> [QuizResponse] {
        let url = baseURL.appendingPathComponent("items")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([QuizResponse].self, from: data)
    }

    // Add more endpoint calls here as the pipeline grows, e.g.:
    // func submitAnswer(question: String, correctAnswer: String, userAnswer: String) async throws -> Evaluation
}

// MARK: - View

struct APIService: View {
    @State private var items: [QuizResponse] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .padding(.bottom)

            List(items) { item in
                Text(item.response)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
        .padding()
        .task {
            await loadItems()
        }
    }

    private func loadItems() async {
        do {
            items = try await BackendService.shared.fetchItems()
        } catch {
            errorMessage = "Couldn't load items: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
}
