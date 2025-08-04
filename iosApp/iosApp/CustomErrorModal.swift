//
//  CustomErrorModal.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUICore
import SwiftUI

struct CustomErrorModal: View {
    let errorMessage: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Modal content
            VStack(spacing: 24) {
                // App Icon
                Image("AppErrorImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(spacing: 16) {
                    // Error title
                    Text("Whoops!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Something went wrong!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Error message
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                
                // Dismiss button
                Button(action: onDismiss) {
                    Text("Try Again")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .stroke(Color.accentColor, lineWidth: 2)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.8)))
        .zIndex(1000)
    }
}

// Custom ViewModifier for showing error modal
struct ErrorModal: ViewModifier {
    @Binding var isPresented: Bool
    let errorMessage: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                CustomErrorModal(
                    errorMessage: errorMessage,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }
                )
                .animation(.easeInOut(duration: 0.3), value: isPresented)
            }
        }
    }
}

// Extension for easy use
extension View {
    func errorModal(isPresented: Binding<Bool>, errorMessage: String) -> some View {
        self.modifier(ErrorModal(isPresented: isPresented, errorMessage: errorMessage))
    }
}
