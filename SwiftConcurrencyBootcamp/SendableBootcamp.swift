//
//  SendableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Pushpank Kumar on 12/11/25.
//

import Combine
import SwiftUI

actor CurrentUserManager {
    func updateDatabase(userInfo: MyClassUserInfo) {
        
    }
}

struct MyUserInfo: Sendable {
    let name: String
}


class MyClassUserInfo: Sendable {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func updateName() {
        
    }
}

final class MyClassUserInfo1: @unchecked Sendable {
    private var name: String
    
    let queue = DispatchQueue(label: "SendableBootcamp.MyClassUserInfo1")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

class SendableBootcampViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        await manager.updateDatabase(userInfo: MyClassUserInfo(name: "Pushpank"))
    }
}

struct SendableBootcamp: View {
    
    @StateObject var vm = SendableBootcampViewModel()
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                Task {
                    await vm.updateCurrentUserInfo()
                }
            }
    }
}

#Preview {
    SendableBootcamp()
}
