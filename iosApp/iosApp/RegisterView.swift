//
//  RegisterView.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUICore
import SwiftUI


struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showCodeConfirmation = false
    @State private var shouldDismissRegister = false
    @State private var showValidation = false
    
    private var isUsernameEmpty: Bool {
        showValidation && username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isEmailEmpty: Bool {
        showValidation && email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isPasswordEmpty: Bool {
        showValidation && password.isEmpty
    }
    
    private var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter your username", text: $username)
                                .textFieldStyle(CustomTextFieldStyle(isError: isUsernameEmpty))
                                .autocapitalization(.none)
                                .disabled(authViewModel.isLoading)
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
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle(isError: isEmailEmpty))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disabled(authViewModel.isLoading)
                                .onChange(of: email) {
                                    if showValidation && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        showValidation = false
                                    }
                                }
                            
                            if isEmailEmpty {
                                HStack {
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text("Email is required")
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
                                .disabled(authViewModel.isLoading)
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
                                .disabled(authViewModel.isLoading)
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
                    }
                    
                    // Register Button
                    Button(action: {
                        if isFormValid {
                            Task {
                                let success = await authViewModel.register(
                                    username: username,
                                    email: email,
                                    password: password
                                )
                                if success {
                                    showCodeConfirmation = true
                                }
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showValidation = true
                            }
                        }
                    }) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Create Account")
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
                    
                    // Welcome Robot Image
                    Image("WellcomeImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 150)
                        .padding(.top, 16)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showCodeConfirmation) {
                CodeConfirmationView(email: email) {
                    // This closure will be called when the user completes verification
                    shouldDismissRegister = true
                }
            }
            .onChange(of: shouldDismissRegister) {
                if shouldDismissRegister {
                    dismiss()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
