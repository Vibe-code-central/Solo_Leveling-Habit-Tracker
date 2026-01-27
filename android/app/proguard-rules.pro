# Flutter default rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Hive Adapters
-keep class * extends com.hivebox.hive.HiveObject { *; }
-keep class **.TypeAdapter { *; }
-keep class **.Adapter { *; }

# Keep data models
-keep class com.example.solo_leveling.data.models.** { *; }

# Keep Generated code (Freezed/JsonSerializable/Hive)
-keep class **.g.dart { *; }

# Ignore missing Play Store classes (Flutter internal dependency)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.app.**
-keep class io.flutter.app.** { *; }
