//
//  SensorViewModel.swift
//  SproutSpace
//
//  Created by nathan tieu on 6/30/24.
//

import Foundation

struct Sensor {
    var ir: Double
    var uv: Double
    var visible: Double
    var moisture: Double
    var temp: Double
}

class SensorViewModel: ObservableObject {
    @Published var sensor = Sensor(ir: 0.0, uv: 0.0, visible: 0.0, moisture: 0.0, temp: 0.0)
    
    func fetchSensorData() {
//        do {
            // DUMMY INFO REPLACE WITH BACKEND INFO
            // currently using numbers from figma
        self.sensor.ir = 6.0
        self.sensor.uv = 0.01
        self.sensor.visible = 19
        self.sensor.moisture = 0
        self.sensor.temp = 27.5
//        } catch {
//            print("Error retrieving sensor data: \(error)")
//        }
    }
}
