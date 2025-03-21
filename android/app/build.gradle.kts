plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Ensure Google services plugin is applied
}

android {
    namespace = "com.example.curereach"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ Update NDK version to match dependencies

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.curereach"
        minSdk = 23 // ✅ Increase minSdkVersion to 23 to match Firebase dependencies
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Firebase BoM (Bill of Materials) - Manages Firebase dependencies' versions
    implementation(platform("com.google.firebase:firebase-bom:33.9.0"))

    // ✅ Firebase dependencies (Don't specify versions when using BoM)
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")         // 🔹 Authentication
    implementation("com.google.firebase:firebase-firestore")    // 🔹 Firestore database
    implementation("com.google.firebase:firebase-storage")      // 🔹 Cloud Storage
    implementation("com.google.firebase:firebase-messaging")    // 🔹 Push Notifications
}
