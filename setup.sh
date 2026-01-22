#!/bin/bash

echo "🎯 Solo Leveling: Shadow Monarch Setup Script"
echo "=============================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Check Flutter doctor
echo ""
echo "🔍 Running Flutter doctor..."
flutter doctor

echo ""
echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "🔨 Generating Hive adapters..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo ""
echo "🌐 Adding platform support..."
flutter create . --platforms=web,android,ios --project-name=solo_leveling

echo ""
echo "🧪 Testing basic functionality..."
echo "Running test app to verify setup..."
flutter run -d chrome lib/test_main.dart &
TEST_PID=$!

# Wait a few seconds then kill the test
sleep 10
kill $TEST_PID 2>/dev/null

echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 To run the app:"
echo "   flutter run                    # For mobile"
echo "   flutter run -d chrome          # For web"
echo "   flutter run lib/test_main.dart # For testing"
echo ""
echo "📱 Available platforms:"
flutter devices --machine | jq -r '.[].name' 2>/dev/null || echo "   Run 'flutter devices' to see available devices"

echo ""
echo "🎮 Ready to begin your journey as a Hunter!"
echo "   Complete daily quests and unlock the Shadow Monarch's power! 👑⚔️"