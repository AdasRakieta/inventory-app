// Top-level build file where you can add configuration options common to all sub-projects/modules.

// Add legacy buildscript only for plugins not available via the plugins DSL (e.g., Navigation Safe Args 2.3.x)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("androidx.navigation:navigation-safe-args-gradle-plugin:2.3.5")
    }
}
// For Gradle 6.x + AGP 4.2.x, configure repositories for all projects here
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
