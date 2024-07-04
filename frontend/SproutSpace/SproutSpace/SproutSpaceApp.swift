//
//  SproutSpaceApp.swift
//  SproutSpace
//
//  Created by nathan tieu on 6/26/24.
//

import SwiftUI

var apiKey: String = ""

@main
struct SproutSpaceApp: App {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let apiKeyFromEnv = ProcessInfo.processInfo.environment["API_KEY"] {
            apiKey = apiKeyFromEnv
            print(apiKey)
        } else {
            print("API_KEY environment variable is not set.")
        }
        return true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
