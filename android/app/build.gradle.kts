import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ru.yzhjdjq.sws"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ru.yzhjdjq.sws"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        buildConfigField("boolean", "DEBUG", "true")
    }

    signingConfigs {
        create("release") {
            val props = Properties()
            val keyPropsFile = rootProject.file("key.properties")
            if (keyPropsFile.exists()) {
                props.load(keyPropsFile.reader())
                storeFile = file(props["storeFile"] as String)
                storePassword = props["storePassword"] as String
                keyAlias = props["keyAlias"] as String
                keyPassword = props["keyPassword"] as String
            } else {
                throw GradleException("Файл key.properties не найден. Создайте его в папке android/")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            buildConfigField("boolean", "DEBUG", "false")
        }
        debug {
            buildConfigField("boolean", "DEBUG", "true")
        }
    }

    buildFeatures {
        buildConfig = true
    }
}

flutter {
    source = "../.."
}
