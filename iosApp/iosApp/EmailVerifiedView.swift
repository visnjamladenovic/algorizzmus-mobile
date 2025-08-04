//
//  EmailVerifiedView.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUICore
import SwiftUI

struct EmailVerifiedView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToLogin = false
    
    // Add a completion handler to dismiss the entire registration flow
    var onComplete: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 24) {
                    // Success Icon
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                    }
                    
                    VStack(spacing: 16) {
                        Text("Email Verified!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Your email has been successfully verified. You can now sign in to your account.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    // Call the completion handler to dismiss the entire flow
                    onComplete?()
                }) {
                    Text("Continue to Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    EmailVerifiedView()
}
