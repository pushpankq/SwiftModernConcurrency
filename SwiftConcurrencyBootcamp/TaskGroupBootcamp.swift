//
//  TaskGroupBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Pushpank Kumar on 09/11/25.
//

import Combine
import SwiftUI

class TaskGroupBootcampManager {
    func fetchImageWithAsyncLet() async throws-> [UIImage] {
        
        async let fetchedImage1 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchedImage2 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchedImage3 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchedImage4 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchedImage5 = fetchImage(urlString: "https://picsum.photos/200")
        
        let (image1, image2, image3, image4, image5) = await (
            try fetchedImage1,
            try fetchedImage2,
            try fetchedImage3,
            try fetchedImage4,
            try fetchedImage5
        )
        
        return [image1, image3, image2, image4, image5]
    }
    
    func fetchImageWithTaskGroup() async throws -> [UIImage] {
        let urlString = [
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
        ]
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlString.count)
            
            for url in urlString {
                group.addTask {
                    try? await self.fetchImage(urlString: url)
                }
            }
            
            for try await image in group {
                if let image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    func fetchImage(urlString: String) async throws-> UIImage {
        
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        do {
            let data = try await URLSession.shared.data(from: url).0
            
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            print("error: ", error.localizedDescription)
            throw error
        }
    }
}

class TaskGroupBootcampViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupBootcampManager()
    
    func getImages() async {
        if let images = try? await manager.fetchImageWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
    
}

struct TaskGroupBootcamp: View {
    
    let colomns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: colomns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    }
                }
            }.navigationBarTitle("Task Group")
                .task {
                    await viewModel.getImages()
                }
        }
    }
}

#Preview {
    TaskGroupBootcamp()
}
