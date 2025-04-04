import java.util.Properties
import java.io.File

pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.20" apply false
}

include(":app")

val flutterProjectRoot = rootProject.projectDir.parentFile.toPath()
val pluginsProperties = Properties()
val pluginsFile = File(flutterProjectRoot.toFile(), ".flutter-plugins")
if (pluginsFile.exists()) {
    pluginsFile.inputStream().use { pluginsProperties.load(it) }
}

pluginsProperties.forEach { key, value ->
    val name = key as String
    val path = value as String
    val pluginDirectory = flutterProjectRoot.resolve(path).resolve("android").toFile()
    include(":$name")
    project(":$name").projectDir = pluginDirectory
}
