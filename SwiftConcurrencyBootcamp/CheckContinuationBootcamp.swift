//
//  CheckContinuationBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Pushpank Kumar on 10/11/25.
//

import Combine
import SwiftUI

class CheckContinuationBootcampManager {
    
    func getData(url: URL) async throws -> Data {
        
        do {
            let data = try await URLSession.shared.data(from: url).0
            return data
        } catch {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data {
                    continuation.resume(returning: data)
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }.resume()
        }
    }
}

class CheckContinuationBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let manager = CheckContinuationBootcampManager()
    
    func getImage() async {
        
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        do {
            let data = try await manager.getData2(url: url)
            
            await MainActor.run {
                self.image = UIImage(data: data)
            }

        } catch {
            print(error.localizedDescription)
        }
    }
}

struct CheckContinuationBootcamp: View {
    
    @StateObject private var viewModel = CheckContinuationBootcampViewModel()
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .background(Color.red)
        .onAppear {
            Task {
                await viewModel.getImage()
            }
        }
    }
}

#Preview {
    CheckContinuationBootcamp()
}
