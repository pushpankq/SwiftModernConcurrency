//
//  ActorBottcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Pushpank Kumar on 12/11/25.
//
import Combine
import SwiftUI

// 1. What is the problem actors are  solving
// 2. How was the problem solved prior to actors
// 3. Actor can solve the problem

class DataManager {
    static let instance = DataManager()
    
    private init() {}
    
    var data: [String] = []
    
    private let queue = DispatchQueue(label: "MyApp.DataManager")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {
        queue.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
}

actor ActorDataManager {
    static let instance = ActorDataManager()
    
    private init() {}
    
    var data: [String] = []
    
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
}

struct HomeView: View {
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    let manager = ActorDataManager.instance
    @State var text: String = ""
    var body: some View {
        ZStack {
            Color.red.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct BrowserView: View {
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    let manager = ActorDataManager.instance
    @State var text: String = ""
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct ActorBottcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowserView()
                .tabItem {
                    Label("Browser", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorBottcamp()
}
