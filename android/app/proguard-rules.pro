# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.BuildConfig { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase Core
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keepclassmembers class com.google.firebase.auth.** { *; }

# Firestore
-keep class com.google.firebase.firestore.** { *; }
-keepclassmembers class com.google.firebase.firestore.** { *; }
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.signin.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Gson (used by Firebase)
-keep class com.google.gson.** { *; }
-keepclassmembers class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Prevent Parcelable issues
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep model classes (adjust package name if needed)
-keep class com.dairy.** { *; }

# OkHttp (used by Firebase)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Conscrypt (used by Firebase)
-dontwarn org.conscrypt.**
-keep class org.conscrypt.** { *; }

# Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items)
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

# With R8 full mode generic signatures are stripped for classes that are not kept
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation