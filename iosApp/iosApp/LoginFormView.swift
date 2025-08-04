//
//  LoginFormView.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUICore
import SwiftUI


struct LoginFormView: View {
    @Binding var username: String
    @Binding var password: String
    @Binding var showPassword: Bool
    @Binding var showValidation: Bool
    let isLoading: Bool
    
    private var isUsernameEmpty: Bool {
        showValidation && username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isPasswordEmpty: Bool {
        showValidation && password.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Username Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter your username", text: $username)
                    .textFieldStyle(CustomTextFieldStyle(isError: isUsernameEmpty))
                    .autocapitalization(.none)
                    .disabled(isLoading)
                    .onChange(of: username) {
                        if showValidation && !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showValidation = false
                        }
                    }
                
                if isUsernameEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Username is required")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .transition(.opacity)
                }
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ZStack(alignment: .trailing) {
                    Group {
                        if showPassword {
                            TextField("Enter your password", text: $password)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
                    }
                    .textFieldStyle(CustomTextFieldStyle(isError: isPasswordEmpty))
                    .disabled(isLoading)
                    .onChange(of: password) {
                        if showValidation && !password.isEmpty {
                            showValidation = false
                        }
                    }
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                            .frame(width: 20, height: 20)
                    }
                    .padding(.trailing, 12)
                    .disabled(isLoading)
                }
                
                if isPasswordEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Password is required")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .transition(.opacity)
                }
            }
            
            // Forgot Password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    // Handle forgot password
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
        }
    }
}
