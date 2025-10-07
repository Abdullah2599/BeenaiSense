# Keep ML Kit text recognition options
-keep class com.google.mlkit.vision.text.** { *; }

# Keep TensorFlow Lite GPU delegate
-keep class org.tensorflow.lite.** { *; }

# Keep Flutter plugin classes
-keep class io.flutter.** { *; }

# Avoid stripping ML Kit internal models and builder classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.firebase.ml.** { *; }

# Optional: For debugging Proguard issues
-dontwarn com.google.mlkit.**
-dontwarn org.tensorflow.**

# --- New rules for Play Core ---
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**