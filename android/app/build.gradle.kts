import java.io.File
import java.io.FileInputStream
import java.util.Properties

// Função para carregar arquivo .env
fun loadEnvFile(): Properties {
    val envFile = rootProject.file("../.env")  // ou rootProject.file(".env")
    val props = Properties()
    if (envFile.exists()) {
        envFile.forEachLine { line ->
            if (line.isNotBlank() && !line.startsWith("#")) {
                val parts = line.split("=", limit = 2)
                if (parts.size == 2) {
                    props.setProperty(parts[0].trim(), parts[1].trim())
                }
            }
        }
    }
    return props
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.oda2.boardpocket"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.oda2.boardpocket"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val envProps = loadEnvFile()

            keyAlias = envProps.getProperty("BOARD_KEY_ALIAS") ?: System.getenv("KEY_ALIAS")
            keyPassword = envProps.getProperty("BOARD_KEY_PASSWORD") ?: System.getenv("KEY_PASSWORD")
            storeFile = file(envProps.getProperty("BOARD_STORE_FILE") ?: System.getenv("STORE_FILE") ?: "not-found.jks")
            storePassword = envProps.getProperty("BOARD_STORE_PASSWORD") ?: System.getenv("STORE_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // implementation("com.google.android.play:core:1.10.3")
}
