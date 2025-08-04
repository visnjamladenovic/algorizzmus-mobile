package com.snjavi.algorizzmus_mobile.repository

import com.snjavi.algorizzmus_mobile.model.ApiResponse
import com.snjavi.algorizzmus_mobile.model.LoginRequest
import com.snjavi.algorizzmus_mobile.model.RegisterRequest
import com.snjavi.algorizzmus_mobile.model.Token
import com.snjavi.algorizzmus_mobile.model.User
import com.snjavi.algorizzmus_mobile.model.VerificationRequest
import com.snjavi.algorizzmus_mobile.service.AuthService

class AuthRepository {

    companion object {
        private const val DEFAULT_LOGIN_ERROR = "Login failed"
        private const val DEFAULT_REGISTER_ERROR = "Registration failed"
        private const val DEFAULT_VERIFICATION_ERROR = "Email verification failed"
        private const val DEFAULT_LOGOUT_ERROR = "Logout failed"
        private const val DEFAULT_PROFILE_ERROR = "Failed to load profile"
    }

    private val authService = AuthService()

    /**
     * Authenticates user with username and password
     * @param username User's username or email
     * @param password User's password
     * @return ApiResponse containing Token on success or error message on failure
     */
    suspend fun login(username: String, password: String): ApiResponse<Token> {
        val loginRequest = LoginRequest(username, password)

        return authService.login(loginRequest).toApiResponse(
            defaultErrorMessage = DEFAULT_LOGIN_ERROR
        )
    }

    /**
     * Registers a new user account
     * @param username Desired username
     * @param email User's email address
     * @param password User's password
     * @return ApiResponse containing User data on success or error message on failure
     */
    suspend fun register(username: String, email: String, password: String): ApiResponse<User> {
        val registerRequest = RegisterRequest(username, password, email)

        return authService.register(registerRequest).toApiResponse(
            defaultErrorMessage = DEFAULT_REGISTER_ERROR
        )
    }

    /**
     * Verifies user's email with confirmation code
     * @param email User's email address
     * @param code 6-digit verification code
     * @return ApiResponse containing Boolean result
     */
    suspend fun verifyEmail(email: String, code: String): ApiResponse<Boolean> {
        val verificationRequest = VerificationRequest(code)

        return authService.verifyEmail(verificationRequest).toApiResponse(
            defaultErrorMessage = DEFAULT_VERIFICATION_ERROR
        )
    }

    /**
     * Logs out the current user
     * @return Boolean indicating success/failure of logout operation
     */
    suspend fun logout(): ApiResponse<Boolean> {
        return authService.logout().toApiResponse(
            defaultErrorMessage = DEFAULT_LOGOUT_ERROR
        )
    }

    /**
     * Retrieves the current user's profile information
     * @return ApiResponse containing User profile or error message
     */
    suspend fun getProfile(): ApiResponse<User> {
        return authService.getProfile().toApiResponse(
            defaultErrorMessage = DEFAULT_PROFILE_ERROR
        )
    }

    /**
     * Checks if user is currently authenticated
     * @return Boolean indicating authentication status
     */
    fun isLoggedIn(): Boolean {
        return try {
            authService.isLoggedIn()
        } catch (e: Exception) {
            false
        }
    }
}

/**
 * Extension function to convert Result<T> to ApiResponse<T>
 * Provides consistent error handling across all repository methods
 */
private fun <T> Result<T>.toApiResponse(defaultErrorMessage: String): ApiResponse<T> {
    return fold(
        onSuccess = { data ->
            ApiResponse(
                success = true,
                data = data,
                message = null
            )
        },
        onFailure = { exception ->
            ApiResponse(
                success = false,
                data = null,
                message = exception.message?.takeIf { it.isNotBlank() } ?: defaultErrorMessage
            )
        }
    )
}