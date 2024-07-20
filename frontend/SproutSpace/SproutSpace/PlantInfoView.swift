//
//  PlantInfoView.swift
//  SproutSpace
//
//  Created by Tina Nguyen on 7/20/24.
//

import Foundation
import SwiftUI

struct PlantInfoView: View {
    let plant: Plant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let imgUrlString = plant.defaultImage?.small_url,
               let imgUrl = URL(string: imgUrlString) {
                AsyncImage(url: imgUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 300)
                .cornerRadius(8)
            } else {
                Color.gray
                    .frame(height: 300)
                    .cornerRadius(8)
            }
            
            Text(plant.commonName)
                .font(.largeTitle)
                .bold()
            
            Text("Watering Requirements: \(plant.watering)")
                .font(.title2)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Plant Details")
                    .font(.title2) // Smaller font size
            }
        }
    }
}
