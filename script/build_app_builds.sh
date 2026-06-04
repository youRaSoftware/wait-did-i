#!/bin/bash

cd "$(dirname "$0")/.."

echo "========================================"
echo "      Wait, Did I? Build Script"
echo "========================================"
echo ""

# Select Flavor
echo "Select a Flavor:"
echo "1. dev"
echo "2. stage"
echo "3. prod"
echo -n "Enter your choice [1-3]: "
read flavor_choice

case $flavor_choice in
    1) build_flavor="dev" ;;
    2) build_flavor="stage" ;;
    3) build_flavor="prod" ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

echo "Selected flavor: $build_flavor"
echo ""

# Select Platform
echo "Select a Platform:"
echo "1. iOS"
echo "2. Android"
echo -n "Enter your choice [1-2]: "
read platform_choice

case $platform_choice in
    1) platform="iOS" ;;
    2) platform="Android" ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

echo "Selected platform: $platform"
echo ""

# Build
if [ "$platform" = "Android" ]; then
    # Select Android build type
    echo "Select Android build type:"
    echo "1. APK (for testing/direct install)"
    echo "2. AAB (for Google Play Store)"
    echo -n "Enter your choice [1-2]: "
    read android_build_type

    case $android_build_type in
        1) build_type="apk" ;;
        2) build_type="appbundle" ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac

    echo ""

    if [ "$build_type" = "apk" ]; then
        echo "Building Android APK..."
        flutter build apk --flavor=$build_flavor --release

        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Android APK built successfully!"
            echo "📁 Location: build/app/outputs/flutter-apk/app-$build_flavor-release.apk"
        else
            echo "❌ Build failed!"
            exit 1
        fi
    else
        echo "Building Android App Bundle (AAB)..."
        flutter build appbundle --flavor=$build_flavor --release

        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Android AAB built successfully!"
            echo "📁 Location: build/app/outputs/bundle/${build_flavor}Release/app-$build_flavor-release.aab"
            echo ""
            echo "📤 Upload to Google Play Console:"
            echo "   https://play.google.com/console"
        else
            echo "❌ Build failed!"
            exit 1
        fi
    fi

elif [ "$platform" = "iOS" ]; then
    echo "Building iOS Archive..."
    flutter build ipa --flavor=$build_flavor --release

    if [ $? -ne 0 ]; then
        echo "❌ Build failed!"
        exit 1
    fi

    echo ""
    echo "✅ iOS Archive built successfully!"
    echo ""

    # Create exportOptions.plist if not exists
    if [ ! -f "ios/exportOptions.plist" ]; then
        echo "Creating exportOptions.plist..."
        cat > ios/exportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>upload</string>
</dict>
</plist>
EOF
    fi

    echo "Uploading to App Store Connect..."
    echo ""

    xcodebuild -exportArchive \
        -archivePath "$PWD/build/ios/archive/Runner.xcarchive" \
        -exportOptionsPlist ios/exportOptions.plist \
        -exportPath "$PWD/build/ios/ipa/" \
        -allowProvisioningUpdates

    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Successfully uploaded to App Store Connect!"
        echo "📱 Check TestFlight in App Store Connect"
    else
        echo ""
        echo "❌ Upload failed!"
        echo ""
        echo "Try manual upload:"
        echo "  1. Open Transporter app"
        echo "  2. Drag build/ios/ipa/*.ipa"
        exit 1
    fi
fi

echo ""
echo "========================================"
echo "              Done!"
echo "========================================"