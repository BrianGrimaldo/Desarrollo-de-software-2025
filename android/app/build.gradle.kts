plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.1.13356709"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        
        // Cambia de minSdk = 23 a minSdkVersion(23)
        minSdkVersion(23) // <-- Corregido con la función minSdkVersion()

        targetSdkVersion(flutter.targetSdkVersion)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Definir las configuraciones de signing
    signingConfigs {
        create("myDebug") {
            storeFile = file("C:\\Users\\Dark\\.android\\debug.keystore") // Ruta del archivo de claves
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            // Referencia correctamente el signingConfig
            signingConfig = signingConfigs.getByName("myDebug")
        }
    }
}

flutter {
    source = "../.."
}
