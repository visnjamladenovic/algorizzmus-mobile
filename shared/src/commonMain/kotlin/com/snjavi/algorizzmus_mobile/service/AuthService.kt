package com.snjavi.algorizzmus_mobile.service

import com.snjavi.algorizzmus_mobile.client.ApiClient
import com.snjavi.algorizzmus_mobile.model.ApiResponse
import com.snjavi.algorizzmus_mobile.model.LoginRequest
import com.snjavi.algorizzmus_mobile.model.RegisterRequest
import com.snjavi.algorizzmus_mobile.model.Token
import com.snjavi.algorizzmus_mobile.model.User
import com.snjavi.algorizzmus_mobile.model.VerificationRequest
import io.ktor.client.call.*
import io.ktor.client.plugins.auth.Auth
import io.ktor.client.plugins.auth.providers.BearerAuthProvider
import io.ktor.client.plugins.plugin
import io.ktor.client.request.*
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.bodyAsText
import io.ktor.http.*

class AuthService {

    companion object {
        private const val LOGIN_ENDPOINT = "/users/login"
        private const val REGISTER_ENDPOINT = "/users/register"
        private const val VERIFY_ENDPOINT = "/users/verify"
        private const val LOGOUT_ENDPOINT = "/auth/logout"
        private const val PROFILE_ENDPOINT = "/auth/profile"

        private const val ERROR_INVALID_CREDENTIALS = "Invalid credentials"
        private const val ERROR_VERIFICATION_FAILED = "Email verification failed"
        private const val ERROR_PROFILE_FAILED = "Failed to get profile"
        private const val ERROR_REGISTRATION_FAILED = "Registration failed"
    }

    private val client = ApiClient.httpClient

    /**
     * Authenticates user with credentials
     * @param loginRequest User credentials
     * @return Result containing Token on success or Exception on failure
     */
    suspend fun login(loginRequest: LoginRequest): Result<Token> {
        return executeRequest(
            endpoint = LOGIN_ENDPOINT,
            body = loginRequest,
            errorMessage = ERROR_INVALID_CREDENTIALS
        ) { response ->
            when (response.status) {
                HttpStatusCode.Forbidden -> throw Exception(ERROR_INVALID_CREDENTIALS)
                else -> response.body<Token>()
            }
        }
    }

    /**
     * Registers a new user account
     * @param registerRequest User registration data
     * @return Result containing User on success or Exception on failure
     */
    suspend fun register(registerRequest: RegisterRequest): Result<User> {
        return executeRequest(
            endpoint = REGISTER_ENDPOINT,
            body = registerRequest,
            errorMessage = ERROR_REGISTRATION_FAILED
        ) { response ->
            response.body<User>()
        }
    }

    /**
     * Verifies user email with confirmation code
     * @param verificationRequest Email and verification code
     * @return Result containing Boolean success status
     */
    suspend fun verifyEmail(verificationRequest: VerificationRequest): Result<Boolean> {
        return executeRequest(
            endpoint = VERIFY_ENDPOINT,
            body = verificationRequest,
            errorMessage = ERROR_VERIFICATION_FAILED
        ) { response ->
            response.status.isSuccess()
        }
    }

    /**
     * Logs out current user and clears authentication token
     * @return Result containing Boolean success status
     */
    suspend fun logout(): Result<Boolean> {
        return try {
            val response = client.post(LOGOUT_ENDPOINT)

            clearAuthToken()

            if (response.status.isSuccess()) {
                val apiResponse: ApiResponse<Boolean> = response.body()
                Result.success(apiResponse.success)
            } else {
                Result.success(true)
            }
        } catch (e: Exception) {
            clearAuthToken()
            Result.failure<Boolean>(e)
        }
    }

    /**
     * Checks if user is currently authenticated
     * @return Boolean indicating authentication status
     */
    fun isLoggedIn(): Boolean {
        return try {
            ApiClient.httpClient.plugin(Auth).providers
                .filterIsInstance<BearerAuthProvider>()
                .isNotEmpty()
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Retrieves current user profile information
     * @return Result containing User profile or Exception on failure
     */
    suspend fun getProfile(): Result<User> {
        return try {
            val response = client.get(PROFILE_ENDPOINT)
            val apiResponse: ApiResponse<User> = response.body()

            when {
                apiResponse.success && apiResponse.data != null -> {
                    Result.success(apiResponse.data)
                }
                else -> {
                    val errorMsg = apiResponse.message ?: ERROR_PROFILE_FAILED
                    Result.failure(Exception(errorMsg))
                }
            }
        } catch (e: Exception) {
            Result.failure(Exception("$ERROR_PROFILE_FAILED: ${e.message}"))
        }
    }

    /**
     * Generic method to execute POST requests with consistent error handling
     */
    private suspend inline fun <T> executeRequest(
        endpoint: String,
        body: Any,
        errorMessage: String,
        crossinline responseHandler: suspend (HttpResponse) -> T
    ): Result<T> {
        return try {
            val response = client.post(endpoint) {
                contentType(ContentType.Application.Json)
                setBody(body)
            }

            if (response.status.isSuccess()) {
                val result = responseHandler(response)
                Result.success(result)
            } else {
                val errorText = response.bodyAsText()
                val finalError = if (errorText.isNotBlank()) errorText else errorMessage
                Result.failure(Exception(finalError))
            }
        } catch (e: Exception) {
            Result.failure(Exception("$errorMessage: ${e.message}"))
        }
    }

    /**
     * Clears authentication token from the client
     */
    private fun clearAuthToken() {
        try {
            ApiClient.updateAuthToken(null)
        } catch (e: Exception) {
            println("Warning: Failed to clear auth token: ${e.message}")
        }
    }
}