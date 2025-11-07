# 📱 Upbase iOS OTA Distribution

Over-The-Air (OTA) installation page for Upbase iOS AdHoc builds.

## 🎯 Overview

This solution allows installing iOS AdHoc builds directly on devices via a web page, without needing TestFlight or App Store.

## 📁 Files

```
ota/
├── index.html          # Main installation page
├── manifest.plist      # iOS OTA manifest (required)
├── style.css           # Styling
├── versions.json       # Available versions list
├── app-icon.png        # App icon (optional)
└── README.md           # This file
```

## 🚀 Setup Instructions

### 1️⃣ Create GitHub Pages Repository

```bash
# Option A: Use existing repository
cd /path/to/your/repo
mkdir -p docs
cp -r .app_dist/ota/* docs/

# Option B: Create new repository
gh repo create upbase-io/app-dist --public
cd app-dist
cp -r /path/to/.app_dist/ota/* .
```

### 2️⃣ Enable GitHub Pages

1. Go to repository **Settings → Pages**
2. Source: **Deploy from a branch**
3. Branch: **main** / **docs** (or master)
4. Click **Save**
5. Your site will be: `https://upbase-io.github.io/app-dist`

### 3️⃣ Update Configuration

#### In `index.html`:
```javascript
const CONFIG = {
    baseUrl: 'https://upbase-io.github.io/app-dist', // ← Update this
    currentVersion: '1.1.24',
    currentBuild: '250',
    bundleId: 'io.upbase.appdc',
    appName: 'Upbase'
};
```

#### In `manifest.plist`:
```xml
<key>url</key>
<string>https://upbase-io.github.io/app-dist/Upbase-iOS-AdHoc-1.1.24-250.ipa</string>
<!-- ↑ Update to actual IPA URL -->
```

### 4️⃣ Upload IPA File

**Important:** IPA file must be publicly accessible via HTTPS.

**Option A: GitHub Release (Recommended)**
```bash
# Create release with IPA
gh release create v1.1.24-250 \
  --title "iOS AdHoc v1.1.24 (250)" \
  --notes "AdHoc distribution build" \
  Upbase-iOS-AdHoc-1.1.24-250.ipa

# Get download URL (will be like):
# https://github.com/upbase-io/app/releases/download/v1.1.24-250/Upbase-iOS-AdHoc-1.1.24-250.ipa
```

**Option B: GitHub Pages (if < 100MB)**
```bash
# Add IPA to repository
cp Upbase-iOS-AdHoc-1.1.24-250.ipa docs/
git add docs/
git commit -m "Add IPA v1.1.24"
git push
```

**Option C: External Storage**
- AWS S3 (with public URL)
- Firebase Storage
- Google Drive (with direct link)
- Dropbox (with direct link)

### 5️⃣ Test Installation

1. Open `https://upbase-io.github.io/app-dist` on iPhone
2. Tap **"Install on This Device"**
3. Follow the installation steps

---

## 🔄 Auto-Update from GitHub Actions

Add this step to your workflow to auto-publish IPA:

```yaml
- name: 📤 Publish to OTA Distribution
  if: steps.build_adhoc.outcome == 'success'
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    # Get IPA info
    VERSION_NAME="${{ steps.version.outputs.VERSION_NAME }}"
    VERSION_CODE="${{ steps.version.outputs.VERSION_CODE }}"
    IPA_FILE="build/ios/ipa/Upbase-iOS-AdHoc-${VERSION_NAME}-${VERSION_CODE}.ipa"
    
    # Create GitHub release
    gh release create "v${VERSION_NAME}-${VERSION_CODE}" \
      --title "iOS AdHoc v${VERSION_NAME} (${VERSION_CODE})" \
      --notes "AdHoc distribution build" \
      "${IPA_FILE}"
    
    # Get download URL
    IPA_URL="https://github.com/${{ github.repository }}/releases/download/v${VERSION_NAME}-${VERSION_CODE}/$(basename ${IPA_FILE})"
    
    # Clone OTA repo
    git clone https://github.com/upbase-io/app-dist.git ota-dist
    cd ota-dist
    
    # Update manifest.plist
    sed -i "s|<string>https://.*\.ipa</string>|<string>${IPA_URL}</string>|g" manifest.plist
    
    # Update versions.json
    DATE=$(date +"%Y-%m-%d")
    FILE_SIZE=$(ls -lh "${IPA_FILE}" | awk '{print $5}')
    
    cat > versions.json << EOF
    [
      {
        "version": "${VERSION_NAME}",
        "build": "${VERSION_CODE}",
        "date": "${DATE}",
        "size": "${FILE_SIZE}",
        "manifestUrl": "itms-services://?action=download-manifest&url=https://upbase-io.github.io/app-dist/manifest.plist",
        "ipaUrl": "${IPA_URL}",
        "notes": "Latest stable build"
      }
    ]
    EOF
    
    # Commit and push
    git config user.name "GitHub Actions"
    git config user.email "actions@github.com"
    git add manifest.plist versions.json
    git commit -m "Update to v${VERSION_NAME} (${VERSION_CODE})"
    git push
```

---

## 📱 How It Works

### Installation Flow:

```
1. User opens: https://upbase-io.github.io/app-dist
2. User taps: "Install on This Device"
3. iOS opens: itms-services://?action=download-manifest&url=...
4. iOS reads: manifest.plist
5. iOS downloads: IPA from URL in manifest
6. iOS installs: App on device
```

### Required:
- ✅ **HTTPS** - iOS requires secure connection
- ✅ **Valid manifest.plist** - Correct format
- ✅ **Accessible IPA** - Publicly downloadable
- ✅ **Correct Bundle ID** - Must match provisioning profile

---

## 🎨 Customization

### Change Colors:
Edit `style.css`:
```css
/* Primary gradient */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

/* Change to your brand colors */
background: linear-gradient(135deg, #4A90E2 0%, #50C878 100%);
```

### Add App Icon:
1. Export icon as PNG (512x512 or 1024x1024)
2. Save as `app-icon.png`
3. Update in `index.html`:
```html
<img src="app-icon.png" alt="Upbase" class="app-icon">
```

### Add Analytics:
```html
<!-- Add before </body> -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

---

## 🔒 Security Options

### Option 1: Password Protection

Add to `index.html` before content:
```javascript
const PASSWORD = 'upbase2025'; // Change this

const userPassword = prompt('Enter password to access:');
if (userPassword !== PASSWORD) {
    document.body.innerHTML = '<h1 style="text-align:center;margin-top:50vh;">Access Denied</h1>';
    throw new Error('Access denied');
}
```

### Option 2: IP Whitelist

Use Cloudflare Workers or similar to restrict access.

### Option 3: GitHub Private Repository

Use GitHub Pages from private repo (requires GitHub Pro).

---

## 🐛 Troubleshooting

### "Unable to Download App"
- ✅ Check IPA URL is accessible (test in browser)
- ✅ Verify HTTPS (not HTTP)
- ✅ Check manifest.plist format
- ✅ Verify Bundle ID matches

### "Untrusted Enterprise Developer"
1. Settings → General → VPN & Device Management
2. Find app under "Enterprise App"
3. Tap "Trust"

### QR Code Not Working
- ✅ Ensure page URL is correct
- ✅ Check QR code library loaded
- ✅ Test QR code with iPhone Camera app

---

## 📊 Features

- ✅ Modern, responsive design
- ✅ QR code for easy sharing
- ✅ Version history
- ✅ Installation instructions
- ✅ iOS detection
- ✅ Auto-refresh
- ✅ File size display
- ✅ Build metadata

---

## 🔗 URLs

**Production:**
- Install page: `https://upbase-io.github.io/app-dist`
- Manifest: `https://upbase-io.github.io/app-dist/manifest.plist`
- Install URL: `itms-services://?action=download-manifest&url=https://upbase-io.github.io/app-dist/manifest.plist`

**GitHub:**
- Organization: https://github.com/upbase-io
- Releases: https://github.com/upbase-io/app/releases

---

## 📞 Support

- **Email:** support@upbase.io
- **GitHub:** https://github.com/upbase-io
- **Issues:** Create issue in repository

---

## 📄 License

Internal distribution only. Not for public release.

---

**Last Updated:** 2025-11-07  
**Version:** 1.0.0  
**Status:** ✅ Ready to deploy

