package com.snjavi.algorizzmus_mobile.model

import kotlinx.serialization.Serializable

@Serializable
data class Token (
    val accessToken: String,
    val refreshToken: String
)