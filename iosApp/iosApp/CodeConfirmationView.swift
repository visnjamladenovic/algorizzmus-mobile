//
//  CodeConfirmationView.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUICore
import SwiftUI

struct CodeConfirmationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let email: String
    let onComplete: (() -> Void)?
    
    init(email: String, onComplete: (() -> Void)? = nil) {
        self.email = email
        self.onComplete = onComplete
    }
    
    @State private var code = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var showResendButton = false
    @State private var showSuccessView = false
    @State private var resendCountdown = 60
    @State private var showErrorModal = false
    @State private var errorMessage = ""
    
    private var codeString: String {
        code.joined()
    }
    
    private var isCodeComplete: Bool {
        let joinedCode = codeString
        let hasCorrectLength = joinedCode.count == 6
        let hasNoEmptyFields = !joinedCode.contains("")
        return hasCorrectLength && hasNoEmptyFields
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.badge")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("Verify Your Email")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("We've sent a 6-digit verification code to")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text(email)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 24) {
                        // Code Input Fields
                        HStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                TextField("", text: $code[index])
                                    .frame(width: 45, height: 50)
                                    .multilineTextAlignment(.center)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(CodeTextFieldStyle())
                                    .focused($focusedField, equals: index)
                                    .onChange(of: code[index]) {
                                        handleCodeInput(at: index, newValue: code[index])
                                    }
                                    .disabled(authViewModel.isLoading)
                            }
                        }
                        
                        // Verify Button
                        Button(action: verifyCodeAction) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Verify Code")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(buttonBackgroundColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(buttonIsDisabled)
                        
                        // Resend Code Section
                        VStack(spacing: 8) {
                            if showResendButton {
                                Button(action: resendCodeAction) {
                                    Text("Resend Code")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.accentColor)
                                }
                                .disabled(authViewModel.isLoading)
                            } else {
                                Text("Resend code in \(resendCountdown)s")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Verification")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $showSuccessView) {
                EmailVerifiedView(onComplete: {
                    // Call the completion handler passed from RegisterView
                    onComplete?()
                })
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                print("CodeConfirmationView appeared")
                startResendCountdown()
                // Auto-focus first field
                focusedField = 0
            }
            .errorModal(
                isPresented: $showErrorModal,
                errorMessage: errorMessage
            )
            // Keep the existing AuthViewModel error alert as well
            .alert("Error", isPresented: .constant(authViewModel.errorMessage != nil)) {
                Button("OK") {
                    // Clear the error - replace this with the correct method for your AuthViewModel
                    // authViewModel.clearError() or authViewModel.errorMessage = nil
                }
            } message: {
                Text(authViewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Computed Properties
    private var buttonBackgroundColor: Color {
        isCodeComplete ? Color.accentColor : Color.gray.opacity(0.3)
    }
    
    private var buttonIsDisabled: Bool {
        let codeIncomplete = !isCodeComplete
        let viewModelLoading = authViewModel.isLoading
        return codeIncomplete || viewModelLoading
    }
    
    // MARK: - Actions
    private func verifyCodeAction() {
        print("Verify code action called with code: \(codeString)")
        Task {
            do {
                let success = await authViewModel.verifyCode(
                    email: email,
                    code: codeString
                )
                print("Verification result: \(success)")
                if success {
                    print("Code verified successfully, showing success view")
                    showSuccessView = true
                } else {
                    print("Code verification failed")
                    // Clear the code fields
                    clearCodeFields()
                    // Show error message
                    errorMessage = "Invalid verification code. Please try again."
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showErrorModal = true
                    }
                }
            } catch {
                print("Error during verification: \(error)")
                clearCodeFields()
                errorMessage = "Verification failed. Please try again."
                withAnimation(.easeInOut(duration: 0.3)) {
                    showErrorModal = true
                }
            }
        }
    }
    
    private func clearCodeFields() {
        code = Array(repeating: "", count: 6)
        focusedField = 0
    }
    
    private func resendCodeAction() {
        Task {
            // await authViewModel.resendVerificationCode(email: email)
            startResendCountdown()
        }
    }
    
    private func handleCodeInput(at index: Int, newValue: String) {
        // Only allow digits
        let filtered = newValue.filter { $0.isNumber }
        
        if filtered.count > 1 {
            // Handle paste operation
            let characters = Array(filtered.prefix(6))
            for i in 0..<min(characters.count, 6) {
                if i + index < 6 {
                    code[i + index] = String(characters[i])
                }
            }
            // Focus on the last filled field or next empty field
            let nextIndex = min(index + filtered.count, 5)
            focusedField = nextIndex
        } else {
            // Single character input
            code[index] = filtered
            
            if !filtered.isEmpty && index < 5 {
                // Move to next field
                focusedField = index + 1
            }
        }
        
        // Handle backspace (empty string)
        if newValue.isEmpty && index > 0 {
            focusedField = index - 1
        }
    }
    
    private func startResendCountdown() {
        showResendButton = false
        resendCountdown = 60
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if resendCountdown > 0 {
                resendCountdown -= 1
            } else {
                showResendButton = true
                timer.invalidate()
            }
        }
    }
}

// Custom text field style for code input
struct CodeTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
            )
    }
}

#Preview {
    CodeConfirmationView(email: "user@example.com")
        .environmentObject(AuthViewModel())
}
