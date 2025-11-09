//
//  DoTryCatchThrows.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Pushpank Kumar on 31/10/25.
//

import SwiftUI
import Combine
import Foundation

class DoTryCatchThrowsManager {
    let isActive: Bool = false
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("New Text", nil)
        } else {
             return (nil, URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New Text")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitle3() throws -> String {
        if isActive {
            return "New Text"
        } else {
            throw URLError(.badURL)
        }
    }
}

class DoTryCatchThrowsViewModel: ObservableObject {
    
    @Published var text: String = "Starting text..."
    
    let manager = DoTryCatchThrowsManager()
    
    
    func fetchTitle() {
        
        /*
        let returnedValue = manager.getTitle()
        if let title = returnedValue.title {
            text = title
        } else if let error = returnedValue.error {
            text = error.localizedDescription
        }
         */
        
        /*
        let result = manager.getTitle2()
        switch result {
        case .success(let newTitle):
            text = newTitle
        case .failure(let error):
            text = error.localizedDescription
        }
         */
        
        do {
            let newTitle = try manager.getTitle3()
            text = newTitle
        } catch let error {
            text = error.localizedDescription
        }
    }
}

struct DoTryCatchThrows: View {
    
    
    
    @StateObject private var vm = DoTryCatchThrowsViewModel()
    var body: some View {
        Text(vm.text)
            .frame(width: 300, height: 100)
            .background(Color.blue)
            .onTapGesture {
                vm.fetchTitle()
            }
    }
}

#Preview {
    DoTryCatchThrows()
}
