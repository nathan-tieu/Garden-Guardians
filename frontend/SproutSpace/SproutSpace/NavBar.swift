//
//  NavBar.swift
//  SproutSpace
//
//  Created by Tina Nguyen on 6/27/24.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case house
    case leaf
}

struct NavBar: View {
    @Binding var selectedTab: Tab
    private var fillImg: String {
        selectedTab.rawValue + ".fill" //selected tab changes to it's fill img
    }
    
    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? fillImg : tab.rawValue)
                    .font(.system(size:25))
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.1)) {
                            selectedTab = tab
                        }
                    }
                    Spacer()
                }
            }
            .frame(width: nil, height: 60)
            .background(.thinMaterial)
            .cornerRadius(10)
            .padding()
        }
    }
}

struct NavBar_Previews: PreviewProvider {
    static var previews: some View {
        NavBar(selectedTab: .constant(.house))
    }
}
