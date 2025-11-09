//
//  AsyncLetBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Pushpank Kumar on 09/11/25.
//

import SwiftUI

struct AsyncLetBootcamp: View {
    @State private var images: [UIImage] = []
    let colomns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                LazyVGrid(columns: colomns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    }
                }
            }.navigationBarTitle("AsyncLetBootcamp")
                .onAppear {
                    
                    Task {
                        
                        do {
//                            let image1 = try await fetchImage()
//                            self.images.append(image1)
//                            
//                            let image2 = try await fetchImage()
//                            self.images.append(image2)
//                            
//                            let image3 = try await fetchImage()
//                            self.images.append(image3)
//                            
//                            let image4 = try await fetchImage()
//                            self.images.append(image4)
//                            
//                            let image5 = try await fetchImage()
//                            self.images.append(image5)
                            
                            async let fetchedImage1 = fetchImage()
                            async let fetchedImage2 = fetchImage()
                            async let fetchedImage3 = fetchImage()
                            async let fetchedImage4 = fetchImage()
                            async let fetchedImage5 = fetchImage()
                            
                            let (image1, image2, image3, image4, image5) = await (
                                try fetchedImage1,
                                try fetchedImage2,
                                try fetchedImage3,
                                try fetchedImage4,
                                try fetchedImage5
                            )
                            
                            images.append(contentsOf: [image1, image3, image2, image4, image5])
            
                            
                        } catch {
                            print("error: ", error)
                        }
                    }
                }
            
        }
    }
    
    func fetchImage() async throws-> UIImage {
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

#Preview {
    AsyncLetBootcamp()
}
