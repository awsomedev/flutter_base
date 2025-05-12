#!/bin/sh

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Install Flutter dependencies
flutter pub get

# Install CocoaPods dependencies
cd ios
pod install
cd ..

# Print Flutter version for verification
flutter --version 