plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.kapt")
    id("kotlin-parcelize")
    id("androidx.navigation.safeargs.kotlin")
}

android {
    compileSdkVersion(33)

    defaultConfig {
        applicationId = "com.inventory.prd"
        minSdkVersion(26)
        targetSdkVersion(33)
    versionCode = 22
    versionName = "1.9.1"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = "1.8"
    }
    
    buildFeatures {
        viewBinding = true
    }
    
    packagingOptions {
        exclude("META-INF/DEPENDENCIES")
        exclude("META-INF/NOTICE*")
        exclude("META-INF/LICENSE*")
        exclude("META-INF/*.SF")
        exclude("META-INF/*.DSA")
        exclude("META-INF/*.RSA")
    }
}

dependencies {
    // AndroidX Core
    implementation("androidx.core:core-ktx:1.6.0")
    implementation("androidx.appcompat:appcompat:1.3.1")
    implementation("com.google.android.material:material:1.4.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.0")

    // Lifecycle & ViewModel
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.3.1")
    implementation("androidx.lifecycle:lifecycle-livedata-ktx:2.3.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.3.1")

    // Navigation Component
    implementation("androidx.navigation:navigation-fragment-ktx:2.3.5")
    implementation("androidx.navigation:navigation-ui-ktx:2.3.5")

    // RecyclerView
    implementation("androidx.recyclerview:recyclerview:1.2.1")

    // Room Database
    val roomVersion = "2.3.0"
    implementation("androidx.room:room-runtime:$roomVersion")
    implementation("androidx.room:room-ktx:$roomVersion")
    kapt("androidx.room:room-compiler:$roomVersion")

    // ML Kit Barcode Scanning (compatible with older AGP/Gradle)
    implementation("com.google.mlkit:barcode-scanning:16.1.1")

    // CameraX
    val cameraXVersion = "1.0.1"
    implementation("androidx.camera:camera-core:$cameraXVersion")
    implementation("androidx.camera:camera-camera2:$cameraXVersion")
    implementation("androidx.camera:camera-lifecycle:$cameraXVersion")
    implementation("androidx.camera:camera-view:1.0.0-alpha27")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.5.1")

    // Gson for JSON serialization
    implementation("com.google.code.gson:gson:2.8.7")

    // ZXing for QR code generation
    implementation("com.google.zxing:core:3.4.1")

    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito:mockito-core:3.11.2")
    testImplementation("org.mockito.kotlin:mockito-kotlin:3.2.0")
    testImplementation("androidx.room:room-testing:$roomVersion")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.5.1")
    testImplementation("androidx.arch.core:core-testing:2.1.0")

    androidTestImplementation("androidx.test.ext:junit:1.1.3")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.4.0")
    androidTestImplementation("androidx.test:runner:1.4.0")
    androidTestImplementation("androidx.test:rules:1.4.0")
}

// Zebra Printer SDK dependencies
dependencies {
    implementation(files("../ok_mobile_zebra_printer/android/libs/ZSDK_ANDROID_API.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/commons-io-2.2.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/commons-lang3-3.4.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/commons-net-3.1.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/commons-validator-1.4.0.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/core-1.53.0.0.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/httpcore-4.3.1.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/httpmime-4.3.2.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/jackson-annotations-2.2.3.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/jackson-core-2.2.3.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/jackson-databind-2.2.3.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/opencsv-2.2.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/pkix-1.53.0.0.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/prov-1.53.0.0.jar"))
    implementation(files("../ok_mobile_zebra_printer/android/libs/snmp6_1z.jar"))
}

// Custom tasks for quick development workflow
tasks.register("deployDebug") {
    group = "custom"
    description = "Build, install and launch debug APK on connected device"
    dependsOn("installDebug")
    doLast {
        exec {
            workingDir = project.rootDir
            commandLine("cmd", "/c", "C:\\Users\\%USERNAME%\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe", "shell", "am", "start", "-n", "com.inventory.prd/com.example.inventoryapp.ui.main.SplashActivity")
        }
    }
}

tasks.register("quickDeploy") {
    group = "custom"
    description = "Quick build and install debug APK on connected device (no clean)"
    dependsOn("assembleDebug", "installDebug")
}

tasks.register("runOnDevice") {
    group = "custom"
    description = "Launch app on connected device (assumes app is already installed)"
    doLast {
        exec {
            workingDir = project.rootDir
            commandLine("cmd", "/c", "C:\\Users\\%USERNAME%\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe", "shell", "am", "start", "-n", "com.inventory.prd/com.example.inventoryapp.ui.main.SplashActivity")
        }
    }
}