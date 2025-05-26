# TensorFlow Lite
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**
# ML Kit (opsional kalau pakai google_mlkit)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
# TFLite GPU Delegate
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
