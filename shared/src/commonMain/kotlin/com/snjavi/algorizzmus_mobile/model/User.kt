package com.snjavi.algorizzmus_mobile.model

import kotlinx.serialization.Serializable

@Serializable
data class User(
    val username: String,
    val email: String,
    val isVerified: Boolean,
    val role: String
)