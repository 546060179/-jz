plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.kineticui.demo"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.kineticui.demo"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "0.2.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // 将动效库源码纳入编译（避免 JVM/Android 插件冲突）
    sourceSets {
        getByName("main") {
            kotlin.srcDirs(
                "src/main/kotlin",
                "../../packages/android/src/main/kotlin"
            )
        }
    }
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.cardview:cardview:1.0.0")
    implementation("androidx.annotation:annotation:1.7.1")
    implementation("androidx.coordinatorlayout:coordinatorlayout:1.2.0")
}
