//
//  TaskBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Pushpank Kumar on 09/11/25.
//

import Combine
import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    
    func fetchImage() async {
        
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let data = try await URLSession.shared.data(from: url).0
            self.image = UIImage(data: data)
            print("image return  successfully")
        } catch {
            print("error: ", error.localizedDescription)
        }

    }
}

struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click Me") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    @StateObject var viewModel = TaskBootcampViewModel()
    @State var fetchedImageTask: Task<Void, Never>? = nil
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .onDisappear {
            fetchedImageTask?.cancel()
        }
        .onAppear {
            fetchedImageTask = Task {
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    TaskBootcamp()
}
