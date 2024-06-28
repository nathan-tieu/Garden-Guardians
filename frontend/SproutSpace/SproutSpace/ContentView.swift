//
//  ContentView.swift
//  SproutSpace
//
//  Created by nathan tieu on 6/26/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PlantViewModel()
    @State private var selectedTab: Tab = .house
    
    var body: some View {
        NavigationView {
            List(viewModel.plants) { plant in
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
                viewModel.fetchPlantInfo()
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
