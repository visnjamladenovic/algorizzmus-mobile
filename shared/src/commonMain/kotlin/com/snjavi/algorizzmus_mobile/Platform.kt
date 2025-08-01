package com.snjavi.algorizzmus_mobile

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform