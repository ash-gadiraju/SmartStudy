import SwiftUI

// MARK: - Models

struct ChatRequest: Codable {
    let message: String
    let session_id: String
}

struct ChatResponse: Codable {
    let answer: String
    let session_id: String
}

struct ResetResponse: Codable {
    let status: String
    let session_id: String
}

// MARK: - Networking

@MainActor
final class BackendService {
    static let shared = BackendService()

    private let baseURL = URL(string: "http://127.0.0.1:8000")!

    private init() {}

    /// Sends a message to the /chat endpoint and returns the model's answer.
    func sendChat(message: String, sessionID: String = "default") async throws -> ChatResponse {
        let url = baseURL.appendingPathComponent("chat")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            ChatRequest(message: message, session_id: sessionID)
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        // Optional: surface non-200s as readable errors instead of a decode failure
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "no body"
            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Status \(http.statusCode): \(body)"])
        }

        return try JSONDecoder().decode(ChatResponse.self, from: data)
    }

    /// Clears a session's history on the backend.
    func resetSession(sessionID: String = "default") async throws -> ResetResponse {
        var url = baseURL.appendingPathComponent("reset")
        url = url.appending(queryItems: [URLQueryItem(name: "session_id", value: sessionID)])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(ResetResponse.self, from: data)
    }
}

// MARK: - View

struct APIService: View {
    @State private var inputText = "Give me 3 questions on APUSH 1920-1960s major events"
    @State private var answer: String = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Ask something...", text: $inputText)
                .textFieldStyle(.roundedBorder)

            Button("Send") {
                Task { await sendMessage() }
            }
            .disabled(isLoading)

            if isLoading {
                ProgressView()
            }

            ScrollView {
                Text(answer)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
        .padding()
    }

    private func sendMessage() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await BackendService.shared.sendChat(message: inputText, sessionID: "me")
            answer = result.answer
        } catch {
            print("Full error: \(error)")
            errorMessage = "Couldn't reach backend: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
}
