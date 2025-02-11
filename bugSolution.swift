import SwiftUI

func fetchData() async throws -> Data {
    let url = URL(string: "https://api.example.com/data")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

func fetchDataWithRetry(retries: Int = 3, delay: TimeInterval = 2) async throws -> Data {
    var retriesLeft = retries
    while retriesLeft > 0 {
        do {
            return try await fetchData()
        } catch {
            print("Error fetching data: \(error), retries left: \(retriesLeft)")
            retriesLeft -= 1
            if retriesLeft > 0 { 
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
    throw NSError(domain: "fetchDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data after multiple retries"])
}

struct ContentView: View {
    @State private var data: Data? = nil
    @State private var error: Error? = nil
    var body: some View {
        VStack {
            Text("Fetching data...")
            if let data = data {
                Text("Data: \(data.count) bytes")
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
            }
        }
        .task {
            do {
                self.data = try await fetchDataWithRetry()
            } catch {
                self.error = error
            }
        }
    }
} 