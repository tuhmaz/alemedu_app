# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep your model classes
-keep class com.alem.edu.models.** { *; }

# Keep your API related classes
-keep class com.alem.edu.api.** { *; }

# Keep Gson related classes
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Keep OkHttp related classes
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# Keep URL Launcher related classes
-keep class com.google.android.gms.** { *; }
-keep class androidx.** { *; }

# Keep image picker related classes
-keep class io.flutter.plugins.imagepicker.** { *; }
