//
//  GeoCoverageApp.swift
//  GeoCoverage
//
//  Created by Martin Davy on 10/7/23.
//

import SwiftUI

@main
struct GeoCoverageApp: App {
    
    @State private var boundaries = Boundaries()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(boundaries)
        }
    }
}
