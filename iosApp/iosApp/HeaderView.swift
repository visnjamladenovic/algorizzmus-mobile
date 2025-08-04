//
//  HeaderView.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUICore
import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            // App Logo
            Image("AppIconImage") // Replace with your actual image set name
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16)) // Optional: rounds the corners like iOS icons
            
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Text("Welcome to Algo")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("rizz")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    Text("mus")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Text("Sign in to your account")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 20)
    }
}
