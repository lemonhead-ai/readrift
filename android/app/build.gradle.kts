plugins {
    id("com.android.application")
    id("kotlin-android")
    // Add the Google Services Gradle plugin
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.firebase.firebase-perf")
}

android {
    namespace = "com.example.elevens"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.elevens"
        minSdk = 23 // Updated to 23 to meet Firebase requirements
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs["debug"]
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BOM to manage Firebase library versions
    implementation(platform("com.google.firebase:firebase-bom:33.3.0"))

    // Add Firebase products (dependencies are managed by the BOM, so no versions needed)
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-perf")
}