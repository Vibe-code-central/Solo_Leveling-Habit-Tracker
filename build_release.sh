#!/bin/bash

# Build script for Solo Leveling Habit Tracker (Optimized Release)

echo "🚀 Starting Optimized Release Build..."

# Clean previous builds
echo "🧹 Cleaning..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build APK with Obfuscation and Split Debug Info
# This minimizes size and secures the code
echo "🔨 Building APK (Obfuscated)..."
flutter build apk --release --obfuscate --split-debug-info=./build/app/outputs/symbols

echo "✅ Build Complete!"
echo "📍 APK Location: build/app/outputs/flutter-apk/app-release.apk"
