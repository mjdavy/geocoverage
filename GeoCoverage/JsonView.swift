//
//  JsonView.swift
//  GeoCoverage
//
//  Created by Martin Davy on 10/9/23.
//

import SwiftUI

struct JsonView: View {
    let jsonString: String
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            ScrollView {
                Text(jsonString)
            }.font(.system(size: 16))
                .padding()
            
            Button("Copy") {
                UIPasteboard.general.string = jsonString
                showAlert = true
            }
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Alert"), message: Text("Copied to clipboard."), dismissButton: .default(Text("Dismiss")))
            })
            .padding()
        }
    }
}

#Preview {
    JsonView(jsonString: "a load of json")
}
