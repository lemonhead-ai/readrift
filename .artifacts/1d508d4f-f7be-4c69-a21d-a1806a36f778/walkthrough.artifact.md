# Walkthrough - Java 17 Upgrade

I have upgraded the project's Java compatibility settings to resolve the obsolete Java 8 warnings.

## Changes Made

### 1. App-level Build Configuration
In [app/build.gradle.kts](file:///C:/Users/marti/StudioProjects/readrift/android/app/build.gradle.kts), I updated the Java and Kotlin target versions:
```kotlin
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
```

### 2. Global Plugin Synchronization
In the root [build.gradle.kts](file:///C:/Users/marti/StudioProjects/readrift/android/build.gradle.kts), I used a task-based configuration to force all subprojects (Flutter plugins) to use Java 17. This approach is safer than `afterEvaluate` as it avoids evaluation timing conflicts.

```kotlin
subprojects {
    project.evaluationDependsOn(":app")
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions.jvmTarget = "17"
    }
}
```

## Verification Results

### Manual Verification
To verify the fix:
1. Run `flutter clean`.
2. Run `flutter run` or `flutter build apk`.
3. Check the console output for the "source value 8 is obsolete" warning. It should no longer appear.
