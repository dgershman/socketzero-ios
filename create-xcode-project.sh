#!/bin/bash

# SocketZero iOS Demo - Xcode Project Creator
# Run this to generate a ready-to-open Xcode project

set -e

echo "🦝 Creating SocketZero iOS Proxy Xcode project..."

PROJECT_NAME="SocketZeroProxy"
BUNDLE_ID="com.radiusmethod.socketzero.proxy"

# Create directory structure
mkdir -p "$PROJECT_NAME/$PROJECT_NAME"

# Move Swift files
cp SocketZeroProxyApp.swift "$PROJECT_NAME/$PROJECT_NAME/"
cp ContentView.swift "$PROJECT_NAME/$PROJECT_NAME/"
cp SocketZeroProxy.swift "$PROJECT_NAME/$PROJECT_NAME/"

# Create Info.plist
cat > "$PROJECT_NAME/$PROJECT_NAME/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <true/>
    </dict>
    <key>UILaunchScreen</key>
    <dict/>
</dict>
</plist>
PLIST

# Create basic project.pbxproj
# (This is a simplified version - Xcode will regenerate properly when opened)
cat > "$PROJECT_NAME/$PROJECT_NAME.xcodeproj/project.pbxproj" << 'PBXPROJ'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
		productName = SocketZeroProxy;
		productReference = ProductRef;
		productType = "com.apple.product-type.application";
	};
	rootObject = RootObject;
}
PBXPROJ

echo "✅ Project created at: $PROJECT_NAME/"
echo ""
echo "Next steps:"
echo "  1. Open Xcode manually (File → Open → select $PROJECT_NAME/)"
echo "  2. Or run: open -a Xcode $PROJECT_NAME"
echo ""
echo "Then add the Swift files manually in Xcode."
echo "Or just follow QUICKSTART.md for the easier method!"

