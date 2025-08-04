package com.snjavi.algorizzmus_mobile.client

import io.ktor.client.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.auth.Auth
import io.ktor.client.plugins.auth.providers.BearerTokens
import io.ktor.client.plugins.auth.providers.bearer
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

object ApiClient {
    private var authToken: String? = null

    fun updateAuthToken(token: String?) {
        authToken = token
    }

    val httpClient = HttpClient {
        install(ContentNegotiation) {
            json(Json {
                prettyPrint = true
                isLenient = true
                ignoreUnknownKeys = true
            })
        }

        install(Logging) {
            logger = Logger.DEFAULT
            level = LogLevel.HEADERS
        }

        install(Auth) {
            bearer {
                loadTokens {
                    authToken?.let { token ->
                        BearerTokens(token, token)
                    }
                }
            }
        }

        install(DefaultRequest) {
            url("http://172.20.10.5:8080")
            headers.append("Content-Type", "application/json")
        }

        install(HttpTimeout) {
            requestTimeoutMillis = 30000
            connectTimeoutMillis = 30000
            socketTimeoutMillis = 30000
        }
    }
}