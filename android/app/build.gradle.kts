// --- Import Java (PENTING) ---
import java.util.Properties
import java.nio.charset.Charset
// -----------------------------

plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charset.forName("UTF-8")).use { reader ->
        localProperties.load(reader)
    }
}

val flutterVersionCode: String? = localProperties.getProperty("flutter.versionCode")
val flutterVersionName: String? = localProperties.getProperty("flutter.versionName")

android {
    namespace = "com.example.ta_teori" // <-- Sesuaikan jika perlu
    
    // --- PERBAIKAN: Ubah ke 36 ---
    compileSdk = 36
    // ---------------------------

    ndkVersion = flutter.ndkVersion

    // Perbaikan untuk 'flutter_local_notifications'
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.example.ta_teori" // <-- Sesuaikan jika perlu
        minSdk = flutter.minSdkVersion 
        
        // --- PERBAIKAN: Ubah ke 36 ---
        targetSdk = 36
        // ---------------------------

        versionCode = (flutterVersionCode ?: "1").toInt()
        versionName = flutterVersionName ?: "1.0"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(kotlin("stdlib-jdk7")) 
    
    // Perbaikan untuk 'flutter_local_notifications'
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
