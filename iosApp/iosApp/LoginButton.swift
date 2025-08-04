//
//  LoginButton.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUICore
import SwiftUI


struct LoginButton: View {
    let action: () async -> Void
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button(action: {
            Task {
                await action()
            }
        }) {
            HStack {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(authViewModel.isLoading)
    }
}
