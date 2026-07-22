# Implementation Plan - Resolve Obsolete Java 8 Warnings

The goal is to eliminate the Java compiler warnings stating that source/target value 8 is obsolete. This will be achieved by upgrading the Java compatibility settings to Java 17, which is the recommended version for the current Android Gradle Plugin (8.7.0) used in the project.

## User Review Required

> [!IMPORTANT]
> This change upgrades the Java version used for compilation from Java 11 to Java 17. Ensure your development environment has JDK 17 or higher installed (which is standard for modern Flutter/Android Studio versions).

## Proposed Changes

### Android Configuration

#### [MODIFY] [app/build.gradle.kts](file:///C:/Users/marti/StudioProjects/readrift/android/app/build.gradle.kts)
- Upgrade `sourceCompatibility` and `targetCompatibility` to `JavaVersion.VERSION_17`.
- Upgrade `kotlinOptions.jvmTarget` to `"17"`.

#### [MODIFY] [build.gradle.kts](file:///C:/Users/marti/StudioProjects/readrift/android/build.gradle.kts) (Root)
- Add a `subprojects` configuration to ensure all plugins (subprojects) also use Java 17. This addresses warnings coming from dependencies that might still be targeting Java 8.

## Verification Plan

### Manual Verification
- Run `flutter build apk` or `flutter run` and verify that the "source value 8 is obsolete" warnings no longer appear in the console output.
