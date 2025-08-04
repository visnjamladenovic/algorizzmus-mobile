//
//  AuthViewModel.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import Foundation
import Shared


@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authRepository = AuthRepository()
    
    func checkAuthStatus() async {
        // isLoggedIn = authRepository.isLoggedIn()
        // if isLoggedIn {
          //  await loadProfile()
        //}
        return
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func verifyCode(email: String, code: String) async -> Bool {
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authRepository.verifyEmail(
                email: email,
                code: code,
            )
                if response.success {
                    isLoading = false
                    return true
                } else {
                    errorMessage = response.message ?? "Verification failed"
                }
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
        
        isLoading = false
        return false
    }
    
    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authRepository.login(username: username, password: password)
                if response.success {
                    currentUser = User( username: "ilija", email: "ilija", isVerified: true, role: "Admin")
                    isLoggedIn = true
                } else {
                    errorMessage = response.message ?? "Login failed"
                }
            }
         catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func register(username: String, email: String, password: String) async -> Bool {
        
        isLoading = true
        errorMessage = nil
        
        do {
             let response = try await authRepository.register(
                username: username,
                email: email,
                password: password,
            )
                if response.success {
                    currentUser = response.data
                    isLoading = false
                    return true
                } else {
                    errorMessage = response.message ?? "Registration failed"
                }
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
        
        isLoading = false
        return false
    }
    
    func logout() async {
        isLoading = true
        
        do {
            _ = try await authRepository.logout()
        } catch {
            // Continue with logout even if API call fails
        }
        
        currentUser = nil
        isLoggedIn = false
        isLoading = false
    }
    
    func loadProfile() async {
        do {
              let user = try await authRepository.getProfile()
                currentUser = user.data
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }
}
