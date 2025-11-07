# 🚀 GitHub Pages Setup for Upbase OTA Distribution

## ✅ Repository Setup

**Repository:** `upbase-io/app`  
**GitHub Pages URL:** `https://upbase-io.github.io/app`  
**Purpose:** iOS AdHoc OTA Distribution

---

## 📋 Enable GitHub Pages

### Step 1: Go to Settings
```
https://github.com/upbase-io/app/settings/pages
```

### Step 2: Configure Source
1. **Source:** Deploy from a branch
2. **Branch:** `main` (or `master`)
3. **Folder:** `/ (root)`
4. Click **Save**

### Step 3: Wait for Deployment
- First deployment takes 1-2 minutes
- Check status at: `https://github.com/upbase-io/app/actions`
- Green checkmark = deployed successfully

---

## 🌐 Your URLs

### Install Page:
```
https://upbase-io.github.io/app
```

### Manifest:
```
https://upbase-io.github.io/app/manifest.plist
```

### Install URL (share this):
```
itms-services://?action=download-manifest&url=https://upbase-io.github.io/app/manifest.plist
```

---

## 📱 How to Use

### For End Users:
1. Open `https://upbase-io.github.io/app` on iPhone
2. Tap "Install on This Device"
3. Follow prompts to install

### Share via QR Code:
- QR code is auto-generated on the page
- Users scan with iPhone Camera app
- Opens install page automatically

---

## 🔄 Update Process

### When New Build is Ready:

1. **Upload IPA to GitHub Releases:**
```bash
gh release create v1.1.25-251 \
  --title "iOS AdHoc v1.1.25 (251)" \
  Upbase-iOS-AdHoc-1.1.25-251.ipa
```

2. **Update manifest.plist:**
```xml
<string>https://github.com/upbase-io/app/releases/download/v1.1.25-251/Upbase-iOS-AdHoc-1.1.25-251.ipa</string>
```

3. **Update index.html:**
```javascript
const CONFIG = {
    currentVersion: '1.1.25',
    currentBuild: '251',
    ...
};
```

4. **Update versions.json:**
```json
{
  "version": "1.1.25",
  "build": "251",
  ...
}
```

5. **Commit and push:**
```bash
git add manifest.plist index.html versions.json
git commit -m "Update to v1.1.25 (251)"
git push
```

6. **Wait 1-2 minutes** for GitHub Pages to redeploy

---

## 🤖 Auto-Update via GitHub Actions

Add this to `.github/workflows/deploy_store.yml` in the main `upbase-devops` repo:

```yaml
- name: 📤 Update OTA Distribution
  if: success()
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    VERSION="${{ steps.version.outputs.VERSION_NAME }}"
    BUILD="${{ steps.version.outputs.VERSION_CODE }}"
    IPA_FILE="build/ios/ipa/Upbase-iOS-AdHoc-${VERSION}-${BUILD}.ipa"
    
    # Create GitHub release with IPA
    gh release create "v${VERSION}-${BUILD}" \
      --repo upbase-io/app \
      --title "iOS AdHoc v${VERSION} (${BUILD})" \
      --notes "AdHoc distribution build from GitHub Actions" \
      "${IPA_FILE}"
    
    # Get IPA download URL
    IPA_URL="https://github.com/upbase-io/app/releases/download/v${VERSION}-${BUILD}/Upbase-iOS-AdHoc-${VERSION}-${BUILD}.ipa"
    
    # Clone OTA repo and update
    git clone https://github.com/upbase-io/app.git ota-update
    cd ota-update
    
    # Update manifest.plist
    sed -i '' "s|<string>https://github.com/upbase-io/app/releases/download/.*\.ipa</string>|<string>${IPA_URL}</string>|g" manifest.plist
    
    # Update versions.json
    cat > versions.json << EOF
    [
      {
        "version": "${VERSION}",
        "build": "${BUILD}",
        "date": "$(date +%Y-%m-%d)",
        "size": "~68 MB",
        "manifestUrl": "itms-services://?action=download-manifest&url=https://upbase-io.github.io/app/manifest.plist",
        "ipaUrl": "${IPA_URL}",
        "notes": "Latest stable build from CI/CD"
      }
    ]
    EOF
    
    # Update index.html
    sed -i '' "s/currentVersion: '[0-9.]*'/currentVersion: '${VERSION}'/g" index.html
    sed -i '' "s/currentBuild: '[0-9]*'/currentBuild: '${BUILD}'/g" index.html
    
    # Commit and push
    git config user.name "GitHub Actions"
    git config user.email "actions@github.com"
    git add manifest.plist versions.json index.html
    git commit -m "Auto-update to v${VERSION} (${BUILD})"
    git push
```

---

## ✅ Verification

### Check if GitHub Pages is Working:

1. Open `https://upbase-io.github.io/app`
2. Should see beautiful install page
3. QR code should be visible
4. Version info should be correct

### Test Installation:

1. Open page on iPhone
2. Tap install button
3. Should redirect to Settings
4. Complete installation

---

## 📊 Files in This Repository

```
upbase-io/app/
├── index.html          # Main install page
├── manifest.plist      # iOS manifest (required)
├── style.css           # Styling
├── versions.json       # Version tracking
├── update-ota.sh       # Update script
├── .gitignore          # Git ignore
├── README.md           # Main documentation
├── SETUP.md            # Setup guide
├── SUMMARY.md          # Quick overview
└── GITHUB_PAGES_SETUP.md  # This file
```

---

## 🔒 Security Notes

### Public vs Private:
- ✅ Repository: **Public** (for GitHub Pages)
- ✅ GitHub Pages: **Public** (anyone can access)
- ⚠️ IPA in Releases: **Public** (anyone can download)

### To Restrict Access:
1. **Password protect** - Add password prompt in index.html
2. **Private repo** - Requires GitHub Pro/Team
3. **Cloudflare Workers** - Add auth layer
4. **VPN/IP whitelist** - Corporate network only

---

## 🆘 Troubleshooting

### GitHub Pages Not Loading:
```bash
# Check if enabled
open https://github.com/upbase-io/app/settings/pages

# Check deployment status
open https://github.com/upbase-io/app/actions

# Force re-deploy
git commit --allow-empty -m "Trigger deployment"
git push
```

### "Unable to Download App":
- ✅ Verify IPA exists in Releases
- ✅ Check IPA URL in manifest.plist
- ✅ Ensure HTTPS (not HTTP)
- ✅ Test IPA URL in browser

### Page Shows Old Version:
- Clear browser cache (Cmd+Shift+R on Mac)
- Wait 2-3 minutes for GitHub Pages cache
- Check commit is pushed: `git log --oneline -1`

---

## 📞 Support

**GitHub Organization:** https://github.com/upbase-io  
**Repository:** https://github.com/upbase-io/app  
**Documentation:** See README.md, SETUP.md, SUMMARY.md

---

**Last Updated:** 2025-11-08  
**Status:** ✅ Ready for GitHub Pages deployment  
**Next Step:** Enable GitHub Pages in repository settings

