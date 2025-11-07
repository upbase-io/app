# 🚀 Quick Setup Guide

## 📋 Prerequisites

- ✅ GitHub account
- ✅ IPA file ready (from GitHub Actions artifact)
- ✅ 5-10 minutes

---

## 🎯 Setup in 5 Steps

### Step 1: Create GitHub Pages Repository

**Option A: New Repository (Recommended)**
```bash
# Create new public repository
gh repo create upbase-io/app-dist --public

# Clone it
git clone https://github.com/upbase-io/app-dist.git
cd app-dist

# Copy OTA files
cp -r /path/to/.app_dist/ota/* .
```

**Option B: Use Existing Repository**
```bash
cd /path/to/your/repo
mkdir -p docs
cp -r /path/to/.app_dist/ota/* docs/
```

---

### Step 2: Enable GitHub Pages

1. Go to: `https://github.com/upbase-io/app-dist/settings/pages`
2. **Source:** Deploy from a branch
3. **Branch:** `main` (or `master`)
4. **Folder:** `/` (root) or `/docs`
5. Click **Save**
6. Wait 1-2 minutes for deployment

Your URL will be: `https://upbase-io.github.io/app-dist`

---

### Step 3: Upload IPA to GitHub Release

```bash
# Download IPA from GitHub Actions
# Then create release:

gh release create v1.1.24-250 \
  --title "iOS AdHoc v1.1.24 (250)" \
  --notes "AdHoc distribution build" \
  Upbase-iOS-AdHoc-1.1.24-250.ipa

# Get the download URL
gh release view v1.1.24-250 --json assets --jq '.assets[0].url'
```

**Your IPA URL will be:**
```
https://github.com/upbase-io/app/releases/download/v1.1.24-250/Upbase-iOS-AdHoc-1.1.24-250.ipa
```

---

### Step 4: Update Configuration

#### Edit `manifest.plist`:

Find this line:
```xml
<string>https://upbase-io.github.io/app-dist/Upbase-iOS-AdHoc-1.1.24-250.ipa</string>
```

Replace with your actual IPA URL:
```xml
<string>https://github.com/upbase-io/app/releases/download/v1.1.24-250/Upbase-iOS-AdHoc-1.1.24-250.ipa</string>
```

#### Edit `index.html`:

Find `CONFIG` section:
```javascript
const CONFIG = {
    baseUrl: 'https://upbase-io.github.io/app-dist', // ← Your GitHub Pages URL
    currentVersion: '1.1.24',  // ← Current version
    currentBuild: '250',       // ← Current build
    bundleId: 'io.upbase.appdc',
    appName: 'Upbase'
};
```

---

### Step 5: Deploy

```bash
# Add all files
git add .

# Commit
git commit -m "Initial OTA distribution setup"

# Push
git push origin main

# Wait 1-2 minutes for GitHub Pages to deploy
```

---

## ✅ Test Installation

1. Open on iPhone: `https://upbase-io.github.io/app-dist`
2. Tap **"Install on This Device"**
3. Follow installation prompts
4. App appears on Home Screen

---

## 🔄 Update to New Version

### Option 1: Manual Update

```bash
# 1. Update manifest.plist with new IPA URL
# 2. Update versions.json with new version
# 3. Update index.html CONFIG
# 4. Commit and push
```

### Option 2: Use Update Script

```bash
# Download new IPA, create release, get URL
IPA_URL="https://github.com/upbase-io/app/releases/download/v1.1.25-251/Upbase-iOS-AdHoc-1.1.25-251.ipa"

# Run update script
./update-ota.sh 1.1.25 251 "$IPA_URL"

# Review changes
git diff

# Commit and push
git commit -am "Update to v1.1.25"
git push
```

---

## 🤖 Auto-Update from GitHub Actions

Add to `.github/workflows/deploy_store.yml`:

```yaml
- name: 📤 Publish to OTA Distribution
  if: steps.build_adhoc.outcome == 'success'
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    OTA_REPO_TOKEN: ${{ secrets.OTA_REPO_TOKEN }}
  run: |
    VERSION="${{ steps.version.outputs.VERSION_NAME }}"
    BUILD="${{ steps.version.outputs.VERSION_CODE }}"
    IPA="build/ios/ipa/Upbase-iOS-AdHoc-${VERSION}-${BUILD}.ipa"
    
    # Create release with IPA
    gh release create "v${VERSION}-${BUILD}" \
      --title "iOS AdHoc v${VERSION} (${BUILD})" \
      --notes "AdHoc distribution" \
      "${IPA}"
    
    # Get IPA URL
    IPA_URL=$(gh release view "v${VERSION}-${BUILD}" --json assets --jq '.assets[0].url')
    
    # Clone OTA repo
    git clone https://x-access-token:${OTA_REPO_TOKEN}@github.com/upbase-io/app-dist.git ota
    cd ota
    
    # Update using script
    ./update-ota.sh "${VERSION}" "${BUILD}" "${IPA_URL}"
    
    # Push changes
    git config user.name "GitHub Actions"
    git config user.email "actions@github.com"
    git commit -am "Update to v${VERSION}"
    git push
```

**Create `OTA_REPO_TOKEN`:**
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Scopes: `repo` (full access)
4. Add to repository secrets: `OTA_REPO_TOKEN`

---

## 🎨 Customization

### Add Your App Icon

1. Export app icon as PNG (512x512 or 1024x1024)
2. Save as `app-icon.png` in root
3. Commit and push

### Change Colors

Edit `style.css`:
```css
/* Line 7-8 */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
/* Change to your brand colors */
```

### Add Password Protection

Add to `index.html` after `<body>` tag:
```html
<script>
const password = prompt('Enter password:');
if (password !== 'upbase2025') {
    document.body.innerHTML = '<h1>Access Denied</h1>';
    throw new Error('Access denied');
}
</script>
```

---

## 📊 URLs Reference

**Your URLs:**
```
Install Page:   https://upbase-io.github.io/app-dist
Manifest:       https://upbase-io.github.io/app-dist/manifest.plist
Install Link:   itms-services://?action=download-manifest&url=https://upbase-io.github.io/app-dist/manifest.plist
```

**Share via:**
- QR Code (auto-generated on page)
- Direct link
- Email
- Slack message

---

## 🆘 Common Issues

### "Unable to Download App"
- ✅ Verify IPA URL in browser
- ✅ Check HTTPS (not HTTP)
- ✅ Verify manifest.plist updated
- ✅ Wait 5 minutes after GitHub Pages deploy

### "Untrusted Enterprise Developer"
**Normal!** After install:
1. Settings → General → VPN & Device Management
2. Find "Upbase" → Tap "Trust"

### Page Not Loading
- ✅ Check GitHub Pages is enabled
- ✅ Wait 2-3 minutes after push
- ✅ Check repository is public
- ✅ Clear browser cache

---

## ✅ Checklist

```
Setup:
☐ Create GitHub Pages repository
☐ Enable GitHub Pages
☐ Upload IPA to releases
☐ Update manifest.plist
☐ Update index.html
☐ Push to repository
☐ Test on iPhone

Optional:
☐ Add app icon
☐ Customize colors
☐ Add password protection
☐ Setup auto-update
☐ Add analytics
```

---

**Time to Complete:** ~10 minutes  
**Difficulty:** Easy  
**Status:** ✅ Ready to deploy

Need help? Check [README.md](README.md) for detailed documentation.

