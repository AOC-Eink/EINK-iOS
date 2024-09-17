//
//  ProfileView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        Form {
            Section{
                LabeledContent {
                    Image(systemName: "chevron.forward")
                } label: {
                    Text("Language")
                }
                LabeledContent {
                    Image(systemName: "chevron.forward")
                } label: {
                    Text("Setting")
                }
            }
            
            Section{
                LabeledContent {
                    HStack {
                        Text("V 1.0.0")
                        Image(systemName: "chevron.forward")
                    }
                } label: {
                    Text("About")
                }
            }
            
        }
    }
}

#Preview {
    ProfileView()
}
