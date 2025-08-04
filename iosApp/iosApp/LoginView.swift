//
//  LoginView.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUICore
import SwiftUI


struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var showingRegister = false
    @State private var showPassword = false
    @State private var showValidation = false
    @State private var showErrorModal = false
    
    private var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo/Header
                    HeaderView()
                    
                    // Login Form
                    LoginFormView(
                        username: $username,
                        password: $password,
                        showPassword: $showPassword,
                        showValidation: $showValidation,
                        isLoading: authViewModel.isLoading
                    )
                    
                    // Login Button
                    LoginButton {
                        if isFormValid {
                            await authViewModel.login(username: username, password: password)
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showValidation = true
                            }
                        }
                    }
                    
                    // Register Link
                    RegisterLinkView {
                        showingRegister = true
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
            .navigationBarHidden(true)
            .errorModal(
                isPresented: $showErrorModal,
                errorMessage: authViewModel.errorMessage ?? ""
            )
            .onChange(of: authViewModel.errorMessage) {
                if authViewModel.errorMessage != nil {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showErrorModal = true
                    }
                }
            }
            .onChange(of: showErrorModal) {
                if !showErrorModal {
                    authViewModel.errorMessage = nil
                }
            }
            .sheet(isPresented: $showingRegister) {
                RegisterView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
