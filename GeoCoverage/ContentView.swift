//
//  ContentView.swift
//  GeoCoverage
//
//  Created by Martin Davy on 10/7/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @Environment(Boundaries.self) private var boundaries
    @State private var showJSONView = false
    @State private var geoJson = ""

    var body: some View {
        VStack {
            Map {
                ForEach(boundaries.boundaries, id:\.self) { boundary  in
                    MapPolygon(boundary)
                }
            }
            .mapControls {
                MapScaleView()
                MapUserLocationButton() }
            
            HStack {
                Button("load") {
                    load(boundaries:boundaries)
                    
                }
                
                Spacer()
                Button("generate json") {
                    geoJson = generateGeoJSON(for: boundaries.boundaries)
                    showJSONView = true
                    print(geoJson)
                }
                
            }
            .padding()
            
        }
    }
        
}

#Preview {
    ContentView()
}
