//
//  main.swift
//  MainActorVSMainThread
//
//  Created by Pushpank Kumar on 15/11/25.
//

import Combine
import Foundation


// What’s the difference between MainActor and DispatchQueue.main.async?
// MainActor is part of Swift's concurrency model (async/await) and provides a compile-time guarantee that code will run on the main thread.

// 1. Compile-Time Errors with MainActor
@MainActor
class ViewModel: ObservableObject {
    @Published var text: String = ""
    
    func updateText() {
        text = "Updated from MainActor" // ✅ Allowed - we're in @MainActor context
    }
}

func backgroundTask(viewModel: ViewModel) async {
    // ❌ COMPILE ERROR: Call to main actor-isolated instance method 'updateText()'
    // in a synchronous nonisolated context
    //viewModel.updateText()
    
    // ✅ Correct - using await to cross actor boundaries
    await viewModel.updateText()
}

// Example 2: Property Isolation
@MainActor
class DataManager {
    var data: [String] = []
    
    func addItem(_ item: String) {
        data.append(item) // ✅ Allowed - same actor context
    }
}

@MainActor func testIsolation() {
    let manager = DataManager()
    
    // ❌ COMPILE ERROR: Main actor-isolated property 'data' can not be
    // mutated from a non-isolated context
    manager.data.append("test")
    
    // ❌ COMPILE ERROR: Call to main actor-isolated instance method 'addItem'
    // in a synchronous nonisolated context
    manager.addItem("test")
}

// Example 3: Function Isolation


@MainActor
func updateUI() {
    // This function can only be called from main actor context
    print("Updating UI on main thread")
}

func backgroundOperation() async {
    // ❌ COMPILE ERROR: Call to main actor-isolated function 'updateUI()'
    // in a synchronous nonisolated context
    // updateUI()
    
    // ✅ Correct - properly awaited
    await updateUI()
}

// DispatchQueue.main.async - Runtime Only


//class ViewController: UIViewController {
//    var label: UILabel!
//    var data: String = ""
//
//    func dangerousBackgroundOperation() {
//        DispatchQueue.global().async {
//            // ❌ NO COMPILE ERROR - but this is WRONG!
//            // This will crash at runtime if accessed from background thread
//            self.data = "unsafe update"
//            self.label.text = "unsafe" // 💥 RUNTIME CRASH possible
//        }
//    }
//
//    func safeBackgroundOperation() {
//        DispatchQueue.global().async {
//            let result = "processed data"
//
//            // ✅ Correct - but compiler doesn't enforce this
//            DispatchQueue.main.async {
//                self.data = result
//                self.label.text = result
//            }
//        }
//    }
//}


// Example 2: Compiler Can't Detect Missing Dispatch

class NetworkService {
    func fetchData(completion: @escaping (String) -> Void) {
        URLSession.shared.dataTask(with: URL(string: "dgsfgs")!) { data, response, error in
            // ❌ NO COMPILE ERROR - but we're on background thread
            // Compiler has no idea we should be on main thread here
            completion("result") // 💥 Callback might update UI from background
        }.resume()
    }
    
    func fetchDataSafely(completion: @escaping (String) -> Void) {
        URLSession.shared.dataTask(with: URL(string: "dgsfgs")!) { data, response, error in
            // ✅ Correct - but compiler doesn't enforce this pattern
            DispatchQueue.main.async {
                completion("result")
            }
        }.resume()
    }
}

/*
Key Compile-Time Benefits of MainActor

Early Error Detection: Problems are caught during compilation, not in production
Clear Intent: @MainActor explicitly declares threading requirements
Automatic Enforcement: Compiler ensures proper await usage
Refactoring Safety: If you change a function to require main thread, call sites must adapt
 
*/

/*
 When Each Fails
 
 MainActor failures: Compile errors - your code won't build until fixed
 DispatchQueue failures: Runtime crashes, UI glitches, hard-to-debug threading issues
 
 The compile-time safety of MainActor is why it's recommended for new Swift development - it turns potential runtime crashes into compile-time errors that are much easier to fix.
 
 */
