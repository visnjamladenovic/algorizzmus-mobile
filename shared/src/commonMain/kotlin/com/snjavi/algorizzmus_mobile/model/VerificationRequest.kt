package com.snjavi.algorizzmus_mobile.model

import kotlinx.serialization.Serializable

@Serializable
data class VerificationRequest(
    val code: String = "",
)
