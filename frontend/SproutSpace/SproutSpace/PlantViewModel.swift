//
//  PlantViewModel.swift
//  SproutSpace
//
//  Created by Tina Nguyen on 6/27/24.
//

import Foundation

struct Plant: Identifiable, Decodable { //identifiable: unique id, decodable: easily convert to json
    let id: Int
    let commonName: String
    let defaultImage: PlantImage?
    let watering: String

    struct PlantImage: Decodable {
        let small_url: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case commonName = "common_name"
        case defaultImage = "default_image"
        case watering
    }
}

struct PlantResponse: Decodable {
    let data: [Plant]
    let to: Int
    let per_page: Int
    let current_page: Int
    let from: Int
    let last_page: Int
    let total: Int
}

class PlantViewModel: ObservableObject {
    @Published var plants = [Plant]() // if plants arr modified, any respective view will update
    
    func fetchPlantInfo() {
        let apiKey = ""
        let urlString = "https://perenual.com/api/species-list?key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
//          print(String(data: data, encoding: .utf8)!)
            do {
                let decodedData = try JSONDecoder().decode(PlantResponse.self, from: data)
                DispatchQueue.main.async {
                    self.plants = decodedData.data
                }
            } catch {
                print("Error decoding plant data: \(error)")
            }
        }

        task.resume()
    }
}
