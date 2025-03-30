// Add this buildscript block at the very top of your file:
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Use the version that matches your project setup.
        classpath("com.android.tools.build:gradle:7.3.1")
        // Google Services plugin for Firebase.
        classpath("com.google.gms:google-services:4.3.15")
    }
}

// The rest of your file remains the same:
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
