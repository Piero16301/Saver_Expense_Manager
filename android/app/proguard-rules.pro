# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Huawei Mobile Services (HMS) and related dependencies
-dontwarn com.huawei.**
-keep class com.huawei.** { *; }

# Chromium Net (used by HMS)
-dontwarn org.chromium.**
-keep class org.chromium.** { *; }

# Conscrypt (used by HMS)
-dontwarn com.android.org.conscrypt.**
-keep class com.android.org.conscrypt.** { *; }

# Google Play Core (deferred components)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
