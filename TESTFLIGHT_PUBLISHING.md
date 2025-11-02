# TestFlight Publishing Guide for Pockets

## Prerequisites

⚠️ **Important**: TestFlight requires an **Apple Developer Program membership** ($99/year). You cannot use TestFlight with a free Apple Developer account.

If you don't have a paid membership yet:
1. Go to [developer.apple.com/programs](https://developer.apple.com/programs/)
2. Enroll in the Apple Developer Program
3. Wait for approval (usually 24-48 hours)

---

## Step 1: Configure Your App in Xcode

### 1.1 Set Bundle Identifier

1. Open `Pockets.xcodeproj` in Xcode
2. Select the **Pockets** project in the navigator
3. Select the **Pockets** target
4. Go to **Signing & Capabilities** tab
5. Change **Bundle Identifier** from `com.example.Pockets` to something unique:
   - Format: `com.evankwc.pockets` or `com.yourname.pockets`
   - This must be unique across the App Store

### 1.2 Configure Signing

1. In **Signing & Capabilities**:
   - Check **"Automatically manage signing"**
   - Select your **Team** (your Apple Developer account)
   - Xcode will automatically create provisioning profiles

### 1.3 Set Version & Build Number

1. Still in the target settings, go to **General** tab
2. Set:
   - **Version**: `1.0` (or `1.0.0`)
   - **Build**: `1` (increment this for each upload)

---

## Step 2: Create App in App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Sign in with your Apple Developer account
3. Click **My Apps** → **+** → **New App**
4. Fill in the details:
   - **Platform**: iOS
   - **Name**: `Pockets`
   - **Primary Language**: English (or your preference)
   - **Bundle ID**: Select the one you created in Step 1.1
   - **SKU**: `pockets-app` (any unique identifier, not visible to users)
   - **User Access**: Full Access (unless you have a team)
5. Click **Create**

---

## Step 3: Prepare Your App Icon and Screenshots

### App Icon
- You already have this set up in Assets.xcassets/AppIcon.appiconset/
- Make sure all sizes are filled (especially the 1024x1024 one)

### Screenshots (Required for TestFlight)
You'll need screenshots for at least one device size:

**Required sizes:**
- iPhone 6.7" (iPhone 14 Pro Max): 1290 x 2796 pixels
- iPhone 6.5" (iPhone 11 Pro Max): 1242 x 2688 pixels
- Or any modern iPhone size

**Quick way to generate:**
1. Run your app in the Simulator
2. Take screenshots of key screens (Dashboard, Add Expense, History, Settings)
3. Use Simulator → Device → Screenshot (⌘S)

---

## Step 4: Build and Archive Your App

### 4.1 Clean Build Folder

1. In Xcode: **Product** → **Clean Build Folder** (⇧⌘K)

### 4.2 Select Generic iOS Device

1. In the device selector (top toolbar), select **"Any iOS Device"** or **"Generic iOS Device"**
   - Don't select a simulator or connected device

### 4.3 Create Archive

1. **Product** → **Archive**
2. Wait for the build to complete (this may take a few minutes)
3. The **Organizer** window will open automatically showing your archive

---

## Step 5: Upload to App Store Connect

### 5.1 Distribute App

1. In the Organizer window, select your archive
2. Click **Distribute App**
3. Select **App Store Connect**
4. Click **Next**
5. Select **Upload** (not Export)
6. Click **Next**

### 5.2 Distribution Options

1. Leave defaults selected:
   - ✅ Upload your app's symbols (for crash reports)
   - ✅ Manage Version and Build Number
2. Click **Next**

### 5.3 Signing

1. Select **Automatically manage signing** (if not already)
2. Xcode will create/use distribution certificates
3. Click **Next**

### 5.4 Review

1. Review the app information
2. Click **Upload**
3. Wait for upload to complete (progress shown in Xcode)
4. Click **Done** when finished

**Note**: Processing in App Store Connect usually takes 10-30 minutes.

---

## Step 6: Configure TestFlight

### 6.1 Wait for Processing

1. Go back to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **My Apps** → **Pockets** → **TestFlight** tab
3. Wait until you see "Processing complete" and your build appears

### 6.2 Add Test Information (First time only)

1. Click on your build
2. Under **Test Information**, click **Add**
3. Fill in:
   - **What to Test**: Describe what testers should focus on
   - **Feedback Email**: `evankology@gmail.com` (or your contact email)
   - **Marketing URL** (optional): Your website or GitHub repo
   - **Privacy Policy URL** (optional): If you have one
4. Click **Save**

### 6.3 Add Testers

#### Option A: Internal Testing (Fast - up to 100 testers)
1. Go to **Internal Testing** section
2. Click **+** to create a group (e.g., "Internal Testers")
3. Add email addresses of testers
4. Add your build to the group
5. Testers will receive an email invite

#### Option B: External Testing (Slower - up to 10,000 testers, requires review)
1. Go to **External Testing** section
2. Click **+** to create a group
3. Add email addresses
4. Submit for Beta App Review (may take 24-48 hours)
5. Once approved, testers receive invites

**Note**: External testing requires:
- Privacy policy URL (can be simple)
- All app information completed
- Beta review (first time only)

---

## Step 7: Testers Install TestFlight

1. Testers receive an email invite
2. They need to:
   - Install **TestFlight** app from App Store (if not already)
   - Accept the invitation
   - Install your app from TestFlight

---

## Common Issues & Solutions

### Issue: "No accounts with App Store Connect access"
**Solution**: Make sure you're signed in with an account that has App Store Connect access in Xcode:
- **Xcode** → **Settings** → **Accounts** → Add your Apple ID

### Issue: "Missing compliance"
**Solution**: In App Store Connect → App Information, answer:
- **Export Compliance**: Usually "No" for simple apps
- **Content Rights**: Usually "Yes" if you own all content

### Issue: Build processing fails
**Solution**: 
- Check email notifications in App Store Connect
- Look for error messages in App Store Connect → TestFlight → Your Build
- Common issues: Missing app icon, invalid provisioning profiles

### Issue: Can't find "Archive" option
**Solution**: 
- Make sure "Any iOS Device" is selected (not Simulator)
- Make sure you've selected the project, not just a file

---

## Quick Checklist

Before uploading, make sure:
- ✅ Apple Developer Program membership active
- ✅ Bundle ID is unique and registered
- ✅ App icon all sizes filled (especially 1024x1024)
- ✅ Version and Build number set
- ✅ Code signing configured
- ✅ App created in App Store Connect
- ✅ Selected "Any iOS Device" before archiving

---

## Updating Your App

For future updates:

1. Increment **Build** number in Xcode (e.g., `1` → `2`)
2. Optionally increment **Version** (e.g., `1.0` → `1.1`)
3. Archive again (Product → Archive)
4. Upload following Step 5
5. The new build will appear in TestFlight after processing

---

## Resources

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

Good luck! 🚀

