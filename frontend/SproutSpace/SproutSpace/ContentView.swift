//
//  ContentView.swift
//  SproutSpace
//
//  Created by nathan tieu on 6/26/24.
//

import SwiftUI
import UIKit
import Foundation

struct ContentView: View {
    @StateObject private var plantViewModel = PlantViewModel()
    @StateObject private var sensorViewModel = SensorViewModel()
    @State private var selectedTab: Tab = .house
    @State private var lastUpdated: String? = nil
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                switch selectedTab {
                case .house:
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(plantViewModel.plants) { plant in
                                VStack(alignment: .leading) {
                                    if let imageUrlString = plant.defaultImage?.small_url,
                                       let imageUrl = URL(string: imageUrlString) {
                                        AsyncImage(url: imageUrl) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 150)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(height: 150)
                                        .cornerRadius(8)
                                    } else {
                                        Color.gray
                                            .frame(height: 150)
                                            .cornerRadius(2)
                                    }
                                    
                                    Text(plant.commonName)
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    Text("Watering: " + plant.watering)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 8)
                            }
                        }
                        .padding()
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Recommended Plants")
                                .font(.title2) // Smaller font size
                        }
                    }
                    .onAppear {
                        plantViewModel.fetchPlantInfo()
                    }
                case .leaf:
                    VStack {
                        Button(action: {
                            lastUpdated = formattedDate(for: Date())
                            sensorViewModel.fetchSensorData()
                        }) {
                            Text("Last updated: \(lastUpdated != nil ? "\(lastUpdated!)" : "Never")")
                                .padding(10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
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
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Sensor Data")
                                    .font(.title2) // Smaller font size
                            }
                        }                        .onAppear {
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
    
    private func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
