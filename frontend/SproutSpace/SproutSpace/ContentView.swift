//
//  ContentView.swift
//  SproutSpace
//
//  Created by nathan tieu on 6/26/24.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var plantViewModel = PlantViewModel()
    @StateObject private var sensorViewModel = SensorViewModel()
    @State private var selectedTab: Tab = .house
//    @State private var lastUpdated: Date? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                switch selectedTab {
                case .house:
                    List(plantViewModel.plants) { plant in
                        VStack(alignment: .leading) {
                            Text(plant.commonName)
                                .font(.headline)
                            Text("Watering Requirements: " + plant.watering)
                                .font(.subheadline)
                            if let imageUrlString = plant.defaultImage?.small_url,
                               let imageUrl = URL(string: imageUrlString) {
                                AsyncImage(url: imageUrl) {
                                    image in image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 200)
                            } else {
                                ProgressView()
                                    .frame(height: 200)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .navigationTitle("Plants")
                    .onAppear {
                        plantViewModel.fetchPlantInfo()
                    }
                
                case .leaf:
                    VStack {
                        List {
                            Section(header: Text("Sunlight")) {
                                Text(String(format: "IR: %.2f", sensorViewModel.sensor.ir))
                                Text(String(format: "UV: %.2f", sensorViewModel.sensor.uv))
                                Text(String(format: "Visible Light: %.2f", sensorViewModel.sensor.visible))
                            }
                            
                            Section(header: Text("Moisture")) {
                                Text(String(format: "Soil Moisture: %.2f", sensorViewModel.sensor.moisture))
                            }
                            
                            Section(header: Text("Temperature")) {
                                Text(String(format: "%.2f °C", sensorViewModel.sensor.temp))
                            }
                        }
                        .listStyle(.insetGrouped)
                        .navigationTitle("Sensor Data")
                        .onAppear {
                            sensorViewModel.fetchSensorData()
                        }
                    }
                }
            }
        }
        ZStack {
            VStack {
                NavBar(selectedTab: $selectedTab)
            }
        }

    }
}

#Preview {
    ContentView()
}
