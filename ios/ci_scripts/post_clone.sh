#!/bin/bash

# Exit on error
set -e

echo "Installing Flutter dependencies..."
flutter pub get

echo "Installing CocoaPods dependencies..."
cd ios
pod install
cd ..

echo "Flutter setup completed successfully!"