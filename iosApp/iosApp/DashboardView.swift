//
//  DashboardView.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUICore
import SwiftUI


struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = authViewModel.currentUser {
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("Welcome, \(user.username)!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                } else {
                    Text("Loading profile...")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        Task {
                            await authViewModel.logout()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .task {
            await authViewModel.loadProfile()
        }
    }
}
