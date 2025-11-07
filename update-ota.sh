#!/bin/bash

# Auto-update OTA Distribution
# This script updates manifest.plist and versions.json with new IPA info

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "📱 Upbase OTA Distribution Updater"
echo "=================================="
echo ""

# Check arguments
if [ "$#" -lt 3 ]; then
    echo -e "${RED}❌ Missing arguments${NC}"
    echo ""
    echo "Usage: $0 <version> <build> <ipa-url>"
    echo ""
    echo "Example:"
    echo "  $0 1.1.24 250 https://github.com/upbase-io/app/releases/download/v1.1.24-250/Upbase-iOS-AdHoc-1.1.24-250.ipa"
    exit 1
fi

VERSION_NAME=$1
VERSION_CODE=$2
IPA_URL=$3
DATE=$(date +"%Y-%m-%d")

echo "Version: ${VERSION_NAME}"
echo "Build: ${VERSION_CODE}"
echo "IPA URL: ${IPA_URL}"
echo "Date: ${DATE}"
echo ""

# Verify IPA URL is accessible
echo "🔍 Verifying IPA URL..."
if curl --output /dev/null --silent --head --fail "$IPA_URL"; then
    echo -e "${GREEN}✅ IPA URL is accessible${NC}"
else
    echo -e "${RED}❌ IPA URL is not accessible${NC}"
    exit 1
fi

# Get file size from IPA URL
echo "📦 Getting file size..."
FILE_SIZE=$(curl -sI "$IPA_URL" | grep -i content-length | awk '{print $2}' | tr -d '\r')
if [ -n "$FILE_SIZE" ]; then
    FILE_SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1048576" | bc)
    echo -e "${GREEN}✅ File size: ${FILE_SIZE_MB} MB${NC}"
else
    FILE_SIZE_MB="~65"
    echo -e "${YELLOW}⚠️  Could not determine file size, using default${NC}"
fi

# Update manifest.plist
echo ""
echo "📝 Updating manifest.plist..."

MANIFEST_FILE="manifest.plist"
if [ ! -f "$MANIFEST_FILE" ]; then
    echo -e "${RED}❌ manifest.plist not found${NC}"
    exit 1
fi

# Backup
cp "$MANIFEST_FILE" "${MANIFEST_FILE}.backup"

# Update IPA URL
sed -i.tmp "s|<string>https://.*\.ipa</string>|<string>${IPA_URL}</string>|g" "$MANIFEST_FILE"

# Update version
sed -i.tmp "s|<key>bundle-version</key>[[:space:]]*<string>.*</string>|<key>bundle-version</key>\n                <string>${VERSION_NAME}</string>|g" "$MANIFEST_FILE"

# Clean up temp files
rm -f "${MANIFEST_FILE}.tmp"

echo -e "${GREEN}✅ manifest.plist updated${NC}"

# Update versions.json
echo "📝 Updating versions.json..."

VERSIONS_FILE="versions.json"

# Get base URL from IPA URL
BASE_URL=$(echo "$IPA_URL" | sed 's|/Upbase-iOS-AdHoc.*||')

# Create/update versions.json
cat > "$VERSIONS_FILE" << EOF
[
  {
    "version": "${VERSION_NAME}",
    "build": "${VERSION_CODE}",
    "date": "${DATE}",
    "size": "${FILE_SIZE_MB} MB",
    "manifestUrl": "itms-services://?action=download-manifest&url=https://upbase-io.github.io/app-dist/manifest.plist",
    "ipaUrl": "${IPA_URL}",
    "notes": "Latest stable build with bug fixes and improvements"
  }
]
EOF

echo -e "${GREEN}✅ versions.json updated${NC}"

# Update index.html config
echo "📝 Updating index.html..."

INDEX_FILE="index.html"
if [ -f "$INDEX_FILE" ]; then
    cp "$INDEX_FILE" "${INDEX_FILE}.backup"
    
    # Update version in CONFIG
    sed -i.tmp "s/currentVersion: '[0-9.]*'/currentVersion: '${VERSION_NAME}'/g" "$INDEX_FILE"
    sed -i.tmp "s/currentBuild: '[0-9]*'/currentBuild: '${VERSION_CODE}'/g" "$INDEX_FILE"
    
    rm -f "${INDEX_FILE}.tmp"
    
    echo -e "${GREEN}✅ index.html updated${NC}"
else
    echo -e "${YELLOW}⚠️  index.html not found, skipping${NC}"
fi

echo ""
echo -e "${GREEN}✅ OTA Distribution updated successfully!${NC}"
echo ""
echo "📋 Summary:"
echo "  - Version: ${VERSION_NAME} (${VERSION_CODE})"
echo "  - IPA Size: ${FILE_SIZE_MB} MB"
echo "  - Date: ${DATE}"
echo ""
echo "🚀 Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Commit: git commit -am 'Update to v${VERSION_NAME}'"
echo "  3. Push: git push"
echo ""
echo "📱 Install URL:"
echo "  itms-services://?action=download-manifest&url=https://upbase-io.github.io/app-dist/manifest.plist"
echo ""

